using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class NativeReviewProbe : MonoBehaviour
    {
        [Serializable] private class Result {public string engine;public string status;public string physicalAcceptance="PENDING";public bool commercialApproved;public string[] failures;public string[] captures;}
        private readonly List<string> failures=new List<string>();
        private readonly List<string> captures=new List<string>();
        private string output;
        private void Check(bool ok,string message){if(!ok){failures.Add(message);Debug.LogError("RQ_UNITY_PROBE: "+message);}}
        private IEnumerator Frames(int n){for(int i=0;i<n;i++)yield return null;}
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
            Directory.CreateDirectory(output);yield return Frames(20);
            var slice=GetComponent<SliceBootstrap>();var player=slice.Player;
            Check(player!=null&&slice.Hud!=null,"scene failed to initialize");
            if(player==null){Finish();yield break;}
            Check(player.GetComponentInChildren<SpriteRenderer>().sprite!=null,"player sprite missing");
            Check(player.transform.position.y>-.2f&&player.transform.position.y<1,"ground collision/visual origin");
            yield return Capture("entry");
            player.Input.SetStick(Vector2.right);float before=player.transform.position.x;yield return Frames(30);player.Input.Cancel();
            Check(player.transform.position.x>before+.5f,"movement does not advance");
            player.Input.Jump();yield return Frames(5);float first=player.Body.linearVelocity.y;player.Input.Jump();yield return Frames(3);
            Check(first>0&&player.Jumps.Used==2&&player.Body.linearVelocity.y>0,"double jump failed");
            player.Body.position=new Vector2(5,.45f);player.Body.linearVelocity=Vector2.zero;yield return Frames(10);
            player.Input.Attack();yield return Frames(5);
            Check(player.Rules.AttackId>0&&player.Rules.Phase!=AttackPhase.Idle,"attack phases failed");
            yield return Capture("attack");yield return Frames(30);
            player.Input.Guard=true;yield return Frames(2);
            var enemy=FindFirstObjectByType<SliceEnemy>();float enemyHp=enemy.Health;
            Check(player.Receive(1,HitKind.Melee,enemy)==DefenseResult.Parried&&enemy.Health==enemyHp-.5f,"Unity parry/counter response failed");
            yield return Capture("guard_parry");player.Input.Cancel();yield return Frames(25);
            player.Receive(1,HitKind.Melee,null);Check(player.Rules.Health==4,"damage did not reach HUD model");
            yield return Capture("health_damage");
            foreach(var foe in FindObjectsByType<SliceEnemy>(FindObjectsSortMode.None))foe.Damage(99,0);
            yield return Frames(2);slice.ChooseReward(0);
            player.Body.position=new Vector2(55,.45f);yield return Frames(65);
            Check(player.Rules.Health==5&&player.transform.position.x<6&&!player.Rules.Locked,"portal restoration/transition failed");
            yield return Capture("portal_destination");Finish();
        }
        private void Finish()
        {
            var result=new Result{engine=Application.unityVersion,status=failures.Count==0?"PASS":"FAIL",failures=failures.ToArray(),captures=captures.ToArray()};
            File.WriteAllText(Path.Combine(output,"NATIVE_REPORT.json"),JsonUtility.ToJson(result,true));
            Debug.Log(failures.Count==0?"RQ_UNITY_NATIVE_OK":"RQ_UNITY_NATIVE_FAILED");Application.Quit(failures.Count==0?0:1);
        }
    }
}
