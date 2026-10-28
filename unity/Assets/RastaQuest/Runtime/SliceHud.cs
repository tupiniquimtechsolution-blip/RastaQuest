using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.UI;
using UnityEngine.InputSystem;
using RastaQuest.Core;
using System.Collections.Generic;

namespace RastaQuest.Unity
{
    public sealed class SliceHud : MonoBehaviour
    {
        public SlicePlayer Player;
        public SliceInput Input;
        private RectTransform safe;
        private Image health;
        private Text life, status, healed;
        private Text languageLabel, effectsLabel;
        private readonly Dictionary<Text,ReviewLabel> labels = new Dictionary<Text,ReviewLabel>();
        private SliceBootstrap slice;
        private GameObject controls, modal, defeat;
        private GameObject events;
        private Sprite portraitSprite;
        private const string LanguageKey="rastaquest.review.language", ShadowKey="rastaquest.review.reducedShadow";
        private FrameGraphic vignette;
        private bool spanish, reduced;
        private float previous = 5, healNotice;
        private Rect lastArea;
        private Vector2 lastScreen;
        private GameObject settings;
        private GameObject rewards;
        public void Initialize(SlicePlayer player, SliceInput input, SliceBootstrap owner)
        {
            Player=player; Input=input; slice=owner;
            spanish=PlayerPrefs.GetString(LanguageKey,"pt")=="es";
            reduced=PlayerPrefs.GetInt(ShadowKey,0)==1;
            Input.Backgrounded=PauseForFocus;
            var canvas=gameObject.AddComponent<Canvas>(); canvas.renderMode=RenderMode.ScreenSpaceOverlay; canvas.sortingOrder=10;
            var scaler=gameObject.AddComponent<CanvasScaler>(); scaler.uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize; scaler.referenceResolution=new Vector2(1280,720); scaler.matchWidthOrHeight=.5f;
            gameObject.AddComponent<GraphicRaycaster>();
            events=new GameObject("TouchEventSystem"); events.AddComponent<EventSystem>(); events.AddComponent<InputSystemUIInputModule>().AssignDefaultActions();
            vignette=Node<FrameGraphic>(transform,"PeripheralShadow",Vector2.zero,Vector2.zero); Stretch(vignette.rectTransform); vignette.Vignette=true; vignette.raycastTarget=false; vignette.enabled=!reduced;
            safe=Node<RectTransform>(transform,"SafeArea",Vector2.zero,Vector2.zero); Stretch(safe);
            var panel=Node<Image>(safe,"PortraitBackground",new Vector2(22,22),new Vector2(76,84)); panel.color=new Color(.035f,.055f,.055f,.9f);
            var portrait=Node<Image>(safe,"Portrait",new Vector2(26,25),new Vector2(68,77));
            var texture=ReviewArt.Sprite(ReviewArt.Clip("player","idle").frames[0].file).texture;
            portraitSprite=Sprite.Create(texture,new Rect(112,146,40,54),Vector2.one*.5f,64); portrait.sprite=portraitSprite; portrait.preserveAspect=true;
            var portraitFrame=Node<FrameGraphic>(safe,"PortraitFrame",new Vector2(20,20),new Vector2(80,88)); portraitFrame.color=Gold;
            Text(safe,"RASTA QUEST",new Vector2(110,19),new Vector2(310,24),19,Gold);
            var bg=Node<Image>(safe,"HealthBackground",new Vector2(109,46),new Vector2(294,22)); bg.color=new Color(.035f,.045f,.05f,.95f);
            health=Node<Image>(safe,"Health",new Vector2(113,50),new Vector2(286,14)); health.color=new Color(.85f,.72f,.3f);
            var barFrame=Node<FrameGraphic>(safe,"HealthFrame",new Vector2(107,44),new Vector2(298,26)); barFrame.color=Gold;
            life=Text(safe,"",new Vector2(110,76),new Vector2(300,23),17,Color.white);
            status=Text(safe,"",new Vector2(22,118),new Vector2(650,45),16,new Color(.88f,.88f,.8f));
            healed=Text(safe,"",new Vector2(110,99),new Vector2(300,24),17,new Color(.6f,1,.75f));
            controls=new GameObject("GameplayControls",typeof(RectTransform));controls.transform.SetParent(safe,false);Stretch((RectTransform)controls.transform);
            Control("stick",new Vector2(50,65),new Vector2(150,150));
            Control("guard",new Vector2(-340,71),new Vector2(94,94));
            Control("jump",new Vector2(-125,151),new Vector2(94,94));
            Control("attack",new Vector2(-210,41),new Vector2(104,104));
            Button(safe,"II",new Vector2(-76,25),new Vector2(52,46),ToggleSettings);
            // The full-screen scrim consumes touches outside the panel as well.
            var scrim=Node<Image>(transform,"ModalInputShield",Vector2.zero,Vector2.zero);
            Stretch(scrim.rectTransform);scrim.color=new Color(0,0,0,.65f);modal=scrim.gameObject;
            var modalSafe=Node<RectTransform>(modal.transform,"ModalSafeArea",Vector2.zero,Vector2.zero);Stretch(modalSafe);
            settings=Panel(modalSafe,"Settings");
            languageLabel=Button(settings.transform,"",new Vector2(40,40),new Vector2(380,50),()=>{
                spanish=!spanish;PlayerPrefs.SetString(LanguageKey,spanish?"es":"pt");PlayerPrefs.Save();RefreshText();});
            effectsLabel=Button(settings.transform,"",new Vector2(40,110),new Vector2(380,50),()=>{
                reduced=!reduced;vignette.enabled=!reduced;PlayerPrefs.SetInt(ShadowKey,reduced?1:0);PlayerPrefs.Save();RefreshText();});
            LabelButton(settings.transform,ReviewLabel.Continue,180,ToggleSettings);
            rewards=Panel(modalSafe,"PortalUpgradeChoices");
            LabelButton(rewards.transform,ReviewLabel.RestoreHealth,40,()=>slice.ChooseReward(0));
            LabelButton(rewards.transform,ReviewLabel.QuickHands,110,()=>slice.ChooseReward(1));
            LabelButton(rewards.transform,ReviewLabel.StrongAxe,180,()=>slice.ChooseReward(2));
            defeat=Panel(modalSafe,"Defeat");
            var title=Text(defeat.transform,"",new Vector2(40,30),new Vector2(380,42),24,Gold);labels.Add(title,ReviewLabel.Defeated);
            var hint=Text(defeat.transform,"",new Vector2(40,85),new Vector2(380,70),18,Color.white);labels.Add(hint,ReviewLabel.RestartHint);
            LabelButton(defeat.transform,ReviewLabel.Restart,180,()=>slice.RestartRun());
            Resize();RefreshMode();RefreshText();
        }
        private static GameObject Panel(Transform parent,string name)
        {
            var image=Node<Image>(parent,name,Vector2.zero,new Vector2(460,300));
            image.rectTransform.anchorMin=image.rectTransform.anchorMax=image.rectTransform.pivot=Vector2.one*.5f;
            image.color=new Color(.025f,.045f,.05f,.98f);return image.gameObject;
        }
        private void LabelButton(Transform parent,ReviewLabel key,float y,UnityEngine.Events.UnityAction action)
        { labels.Add(Button(parent,"",new Vector2(40,y),new Vector2(380,50),action),key); }
        private void RefreshText()
        {
            foreach(var pair in labels)pair.Key.text=ReviewText.Get(pair.Value,spanish);
            languageLabel.text=ReviewText.Get(ReviewLabel.Language,spanish);
            effectsLabel.text=ReviewText.Get(reduced?ReviewLabel.RestoreShadow:ReviewLabel.ReduceShadow,spanish);
        }
        private static readonly Color Gold=new Color(.82f,.64f,.3f,.95f);
        public static T Node<T>(Transform parent,string name,Vector2 at,Vector2 size) where T:Component
        {
            var o=new GameObject(name,typeof(RectTransform)); o.transform.SetParent(parent,false);
            var r=(RectTransform)o.transform; r.anchorMin=r.anchorMax=new Vector2(at.x<0?1:0,1); r.pivot=new Vector2(0,1); r.anchoredPosition=new Vector2(at.x,-at.y); r.sizeDelta=size;
            if(typeof(T)==typeof(RectTransform)) return o.GetComponent<T>();
            return o.AddComponent<T>();
        }
        private static void Stretch(RectTransform r) {r.anchorMin=Vector2.zero;r.anchorMax=Vector2.one;r.offsetMin=r.offsetMax=Vector2.zero;}
        public static Text Text(Transform parent,string text,Vector2 at,Vector2 size,int fontSize,Color color)
        {
            var t=Node<Text>(parent,"Label",at,size); t.font=Resources.GetBuiltinResource<Font>("LegacyRuntime.ttf");t.text=text;t.fontSize=fontSize;t.color=color;t.raycastTarget=false;return t;
        }
        private static Text Button(Transform parent,string text,Vector2 at,Vector2 size,UnityEngine.Events.UnityAction action)
        {
            var image=Node<Image>(parent,"Button",at,size);image.color=new Color(.1f,.15f,.15f,.96f);
            var button=image.gameObject.AddComponent<Button>();button.onClick.AddListener(action);
            var label=Text(image.transform,text,new Vector2(8,8),size-new Vector2(16,16),19,Color.white);label.alignment=TextAnchor.MiddleCenter;
            return label;
        }
        private void Control(string action,Vector2 at,Vector2 size)
        {
            var ring=Node<FrameGraphic>(controls.transform,action,at,size);ring.Circle=true;ring.color=new Color(.8f,.9f,.86f,.38f);
            ring.rectTransform.anchorMin=ring.rectTransform.anchorMax=new Vector2(at.x<0?1:0,0);
            ring.rectTransform.pivot=new Vector2(0,0);ring.rectTransform.anchoredPosition=at;
            var touch=ring.gameObject.AddComponent<TouchBinding>();touch.Bind(Input,action);
            var icon=Node<ControlIcon>(ring.transform,"Icon",Vector2.zero,size);icon.Action=action;icon.Input=Input;icon.raycastTarget=false;icon.color=new Color(.85f,.94f,.89f,.48f);
        }
        public void ToggleSettings()
        {
            if(slice.Flow.Phase==RoomPhase.Defeated)return;
            if(slice.Flow.Paused)slice.Flow.Resume();else slice.Flow.Pause();
            RefreshMode();
        }
        public void PauseForFocus()
        {
            if(slice==null)return;
            if(Player.Rules.Dead)slice.Flow.Defeat();else slice.Flow.Pause();
            RefreshMode();
        }
        public void RefreshMode()
        {
            bool paused=slice.Flow.Paused, choosing=slice.Flow.Phase==RoomPhase.Rewards, dead=slice.Flow.Phase==RoomPhase.Defeated;
            settings.SetActive(paused);rewards.SetActive(!paused&&choosing);defeat.SetActive(dead);
            bool blocked=paused||choosing||dead;
            modal.SetActive(blocked);
            Input.Paused=blocked||slice.Flow.Phase==RoomPhase.Transition;Input.Cancel();
            controls.SetActive(!Input.Paused);
            Time.timeScale=blocked?0:1;
        }
        public void Rebind(SlicePlayer player)
        {
            Player=player;previous=player.Rules.Health;healNotice=0;RefreshMode();
        }
        private void Resize()
        {
            Input.Cancel();foreach(var binding in GetComponentsInChildren<TouchBinding>()) binding.Release();
            Rect area=Screen.safeArea;lastArea=area;lastScreen=new Vector2(Screen.width,Screen.height);
            safe.anchorMin=new Vector2(area.xMin/Screen.width,area.yMin/Screen.height);safe.anchorMax=new Vector2(area.xMax/Screen.width,area.yMax/Screen.height);safe.offsetMin=safe.offsetMax=Vector2.zero;
            var modalSafe=(RectTransform)modal.transform.GetChild(0);
            modalSafe.anchorMin=safe.anchorMin;modalSafe.anchorMax=safe.anchorMax;modalSafe.offsetMin=modalSafe.offsetMax=Vector2.zero;
        }
        private void Update()
        {
            if(Player==null) return;
            if(Screen.safeArea!=lastArea || lastScreen!=new Vector2(Screen.width,Screen.height)) Resize();
            float hp=Player.Rules.Health;if(hp>previous)healNotice=1.2f;previous=hp;healNotice=Mathf.Max(0,healNotice-Time.unscaledDeltaTime);
            health.rectTransform.sizeDelta=new Vector2(286*Mathf.Clamp01(hp/Player.Rules.MaxHealth),14);
            health.color=hp/Player.Rules.MaxHealth<=.3f?new Color(.95f,.32f,.2f):new Color(.87f,.73f,.3f);
            life.text=ReviewText.Get(ReviewLabel.Health,spanish)+" "+hp.ToString("0.#")+" / "+Player.Rules.MaxHealth.ToString("0.#");
            healed.text=healNotice>0?ReviewText.Get(ReviewLabel.Healed,spanish):"";
            var phase=slice.Flow.Phase;
            var label=slice.Flow.Paused?ReviewLabel.Paused:Player.Rules.Dead?ReviewLabel.Defeated:
                phase==RoomPhase.Rewards?ReviewLabel.Rewards:phase==RoomPhase.Ready?ReviewLabel.PortalReady:
                phase==RoomPhase.Transition?ReviewLabel.Transition:ReviewLabel.Encounter;
            status.text=ReviewText.Get(label,spanish);
            if(Keyboard.current!=null && Keyboard.current.escapeKey.wasPressedThisFrame) ToggleSettings();
        }
        private void OnDestroy()
        {
            Time.timeScale=1;
            if(Input!=null){Input.Backgrounded=null;Input.Cancel();}
            if(events!=null)Destroy(events);
            if(portraitSprite!=null)Destroy(portraitSprite);
        }
    }
}
