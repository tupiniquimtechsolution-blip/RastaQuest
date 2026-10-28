using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using UnityEngine.EventSystems;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class NativeReviewProbe : MonoBehaviour
    {
        [Serializable] private class Result {public string engine;public string version;public string status;public string physicalAcceptance="PENDING";public bool commercialApproved;public string[] failures;public string[] captures;public string method="Synthetic component inputs in real Unity runtime; not physical touch acceptance";}
        private readonly List<string> failures=new List<string>();
        private readonly List<string> captures=new List<string>();
        private string output;
        private bool finished;
        private void OnEnable(){Application.logMessageReceived+=RuntimeLog;}
        private void OnDisable(){Application.logMessageReceived-=RuntimeLog;}
        private void RuntimeLog(string message,string trace,LogType type)
        {
            if((type==LogType.Exception||type==LogType.Error||type==LogType.Assert)&&!message.StartsWith("RQ_UNITY_PROBE:"))
                failures.Add("runtime error: "+message);
        }
        private IEnumerator Watchdog()
        {
            yield return new WaitForSecondsRealtime(120);
            if(!finished){failures.Add("probe timed out before completion");Finish();}
        }
        private void Check(bool ok,string message){if(!ok){failures.Add(message);Debug.LogError("RQ_UNITY_PROBE: "+message);}}
        private IEnumerator Frames(int n){for(int i=0;i<n;i++)yield return null;}
        private static IEnumerator Seconds(float duration){yield return new WaitForSeconds(duration);}
        private IEnumerator Capture(string key)
        {
            yield return new WaitForEndOfFrame();
            var texture=ScreenCapture.CaptureScreenshotAsTexture();
            string path=Path.Combine(output,key+"_"+Screen.width+"x"+Screen.height+".png");
            File.WriteAllBytes(path,texture.EncodeToPNG());Destroy(texture);captures.Add(Path.GetFileName(path));
        }
        private IEnumerator Start()
        {
            output=Path.Combine(Application.persistentDataPath,"unity-review-probe");
            foreach(string arg in Environment.GetCommandLineArgs())if(arg.StartsWith("--rq-output="))output=arg.Substring(12);
            Directory.CreateDirectory(output);StartCoroutine(Watchdog());yield return Frames(20);
            var slice=GetComponent<SliceBootstrap>();var player=slice.Player;
            Check(player!=null&&slice.Hud!=null,"scene failed to initialize");
            if(player==null){Finish();yield break;}
            Check(player.GetComponentInChildren<SpriteRenderer>().sprite!=null,"player sprite missing");
            Check(player.transform.position.y>-.2f&&player.transform.position.y<1,"ground collision/visual origin");
            yield return Capture("entry");
            TouchBinding stick=null;
            foreach(var control in slice.Hud.GetComponentsInChildren<TouchBinding>())
            {
                var rect=(RectTransform)control.transform;var corners=new Vector3[4];rect.GetWorldCorners(corners);
                Rect area=Screen.safeArea;
                Vector2 lower=RectTransformUtility.WorldToScreenPoint(null,corners[0]);
                Vector2 upper=RectTransformUtility.WorldToScreenPoint(null,corners[2]);
                Check(lower.x>=area.xMin-1&&lower.y>=area.yMin-1&&upper.x<=area.xMax+1&&upper.y<=area.yMax+1,"control outside safe area: "+control.Action);
                if(control.Action=="stick")stick=control;
            }
            Check(stick!=null,"analog control missing");
            if(stick==null){Finish();yield break;}
            var stickRect=(RectTransform)stick.transform;
            var pointer=new PointerEventData(EventSystem.current){pointerId=17,position=RectTransformUtility.WorldToScreenPoint(null,stickRect.TransformPoint(stickRect.rect.center))};
            stick.OnPointerDown(pointer);Check(player.Input.Stick.sqrMagnitude<.001f,"touch at analog center must be neutral");
            player.Input.Cancel();
            pointer.position=RectTransformUtility.WorldToScreenPoint(null,stickRect.TransformPoint(stickRect.rect.center+Vector2.right*stickRect.rect.width*.48f));
            stick.OnPointerDown(pointer);Check(player.Input.Horizontal>.5f,"cancel must release analog pointer ownership");stick.OnPointerUp(pointer);
            slice.Hud.ToggleSettings();float pausedX=player.transform.position.x;
            player.Input.SetStick(Vector2.right);player.Input.Jump();player.Input.Attack();yield return Frames(3);
            Check(Time.timeScale==0&&player.Input.Horizontal==0&&!player.Input.TakeAttack()&&!player.Input.TakeJump()&&player.transform.position.x==pausedX,"pause leaked gameplay input");
            yield return Capture("pause");slice.Hud.ToggleSettings();
            player.Input.SetStick(Vector2.right);float before=player.transform.position.x;yield return Seconds(.5f);player.Input.Cancel();
            Check(player.transform.position.x>before+.5f,"movement does not advance");
            player.Input.Jump();yield return Seconds(.08f);float first=player.Body.linearVelocity.y;player.Input.Jump();yield return Seconds(.05f);
            Check(first>0&&player.Jumps.Used==2&&player.Body.linearVelocity.y>0,"double jump failed");
            player.Body.position=new Vector2(5,.45f);player.Body.linearVelocity=Vector2.zero;yield return Seconds(.2f);
            player.Input.Attack();yield return Seconds(.08f);
            Check(player.Rules.AttackId>0&&player.Rules.Phase!=AttackPhase.Idle,"attack phases failed");
            yield return Capture("attack");yield return Seconds(.5f);
            player.Input.Guard=true;yield return Seconds(.04f);
            var enemy=FindFirstObjectByType<SliceEnemy>();Check(enemy!=null,"enemy missing");if(enemy==null){Finish();yield break;}float enemyHp=enemy.Health;
            Check(player.Receive(1,HitKind.Melee,enemy)==DefenseResult.Parried&&enemy.Health==enemyHp-.5f,"Unity parry/counter response failed");
            yield return Capture("guard_parry");player.Input.Cancel();yield return Seconds(.42f);
            player.Receive(1,HitKind.Melee,null);Check(player.Rules.Health==4,"damage did not reach HUD model");
            yield return Capture("health_damage");
            foreach(var foe in FindObjectsByType<SliceEnemy>(FindObjectsSortMode.None))foe.Damage(99,0);
            yield return Frames(2);Check(slice.Flow.Phase==RoomPhase.Rewards&&Time.timeScale==0,"reward modal failed");
            yield return Capture("reward_choices");slice.ChooseReward(0);
            player.Body.position=new Vector2(55,.45f);yield return Seconds(1.1f);
            Check(player.Rules.Health==5&&player.transform.position.x<6&&!player.Rules.Locked&&slice.Flow.Biome==1,"portal restoration/transition failed");
            yield return Capture("portal_destination");
            player.Receive(1,HitKind.Melee,null);
            foreach(var foe in FindObjectsByType<SliceEnemy>(FindObjectsSortMode.None))foe.Damage(99,0);
            yield return Frames(2);float hp=player.Rules.Health;slice.ChooseReward(2);slice.ChooseReward(2);
            Check(player.Damage==2,"duplicate reward applied");
            player.Body.position=new Vector2(55,.45f);yield return Frames(2);slice.Hud.PauseForFocus();
            float transition=slice.Flow.TransitionRemaining;yield return Frames(5);
            Check(slice.Flow.TransitionRemaining==transition&&Time.timeScale==0,"background advanced portal");
            slice.Hud.ToggleSettings();yield return Seconds(1.1f);
            Check(player.Rules.Health==hp&&slice.Flow.Biome==2,"non-healing choice restored life or failed transition");
            yield return Capture("non_healing_destination");
            player.Receive(99,HitKind.Area,null);yield return Seconds(.7f);
            Check(slice.Flow.Phase==RoomPhase.Defeated&&Time.timeScale==0,"defeat screen failed");
            yield return Capture("defeat");slice.RestartRun();yield return Frames(5);
            Check(slice.Player!=player&&slice.Player.Rules.Health==5&&slice.Player.Damage==1&&slice.Flow.Biome==0&&Time.timeScale==1,"restart did not reset run");
            yield return Capture("restart");Finish();
        }
        private void Finish()
        {
            if(finished)return;finished=true;
            var result=new Result{engine=Application.unityVersion,version=Application.version,status=failures.Count==0?"PASS":"FAIL",failures=failures.ToArray(),captures=captures.ToArray()};
            File.WriteAllText(Path.Combine(output,"NATIVE_REPORT.json"),JsonUtility.ToJson(result,true));
            Debug.Log(failures.Count==0?"RQ_UNITY_NATIVE_OK":"RQ_UNITY_NATIVE_FAILED");Application.Quit(failures.Count==0?0:1);
        }
    }
}
