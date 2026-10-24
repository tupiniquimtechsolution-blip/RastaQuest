using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem.UI;
using UnityEngine.InputSystem;

namespace RastaQuest.Unity
{
    public sealed class SliceHud : MonoBehaviour
    {
        public SlicePlayer Player;
        public SliceInput Input;
        private RectTransform safe;
        private Image health;
        private Text life, status, healed;
        private Text languageLabel, effectsLabel, agileLabel, damageLabel;
        private FrameGraphic vignette;
        private bool spanish, reduced;
        private float previous = 5, healNotice;
        private Rect lastArea;
        private Vector2 lastScreen;
        private GameObject settings;
        private GameObject rewards;
        public void Initialize(SlicePlayer player, SliceInput input)
        {
            Player=player; Input=input;
            var canvas=gameObject.AddComponent<Canvas>(); canvas.renderMode=RenderMode.ScreenSpaceOverlay; canvas.sortingOrder=10;
            var scaler=gameObject.AddComponent<CanvasScaler>(); scaler.uiScaleMode=CanvasScaler.ScaleMode.ScaleWithScreenSize; scaler.referenceResolution=new Vector2(1280,720); scaler.matchWidthOrHeight=.5f;
            gameObject.AddComponent<GraphicRaycaster>();
            var events=new GameObject("TouchEventSystem").AddComponent<EventSystem>(); events.gameObject.AddComponent<InputSystemUIInputModule>().AssignDefaultActions();
            vignette=Node<FrameGraphic>(transform,"PeripheralShadow",Vector2.zero,Vector2.zero); Stretch(vignette.rectTransform); vignette.Vignette=true; vignette.raycastTarget=false;
            safe=Node<RectTransform>(transform,"SafeArea",Vector2.zero,Vector2.zero); Stretch(safe);
            var panel=Node<Image>(safe,"PortraitBackground",new Vector2(22,22),new Vector2(76,84)); panel.color=new Color(.035f,.055f,.055f,.9f);
            var portrait=Node<Image>(safe,"Portrait",new Vector2(26,25),new Vector2(68,77));
            var texture=ReviewArt.Sprite(ReviewArt.Clip("player","idle").frames[0].file).texture;
            portrait.sprite=Sprite.Create(texture,new Rect(112,146,40,54),Vector2.one*.5f,64); portrait.preserveAspect=true;
            var portraitFrame=Node<FrameGraphic>(safe,"PortraitFrame",new Vector2(20,20),new Vector2(80,88)); portraitFrame.color=Gold;
            Text(safe,"RASTA QUEST",new Vector2(110,19),new Vector2(310,24),19,Gold);
            var bg=Node<Image>(safe,"HealthBackground",new Vector2(109,46),new Vector2(294,22)); bg.color=new Color(.035f,.045f,.05f,.95f);
            health=Node<Image>(safe,"Health",new Vector2(113,50),new Vector2(286,14)); health.color=new Color(.85f,.72f,.3f);
            var barFrame=Node<FrameGraphic>(safe,"HealthFrame",new Vector2(107,44),new Vector2(298,26)); barFrame.color=Gold;
            life=Text(safe,"",new Vector2(110,76),new Vector2(300,23),17,Color.white);
            status=Text(safe,"",new Vector2(22,118),new Vector2(650,45),16,new Color(.88f,.88f,.8f));
            healed=Text(safe,"",new Vector2(110,99),new Vector2(300,24),17,new Color(.6f,1,.75f));
            Control("stick",new Vector2(50,505),new Vector2(150,150));
            Control("guard",new Vector2(-340,555),new Vector2(94,94));
            Control("jump",new Vector2(-125,475),new Vector2(94,94));
            Control("attack",new Vector2(-210,575),new Vector2(104,104));
            Button(safe,"II",new Vector2(-76,25),new Vector2(52,46),ToggleSettings);
            settings=new GameObject("Settings",typeof(RectTransform)); settings.transform.SetParent(safe,false);
            var settingsRect=(RectTransform)settings.transform; settingsRect.anchorMin=settingsRect.anchorMax=new Vector2(.5f,.5f); settingsRect.pivot=Vector2.one*.5f; settingsRect.sizeDelta=new Vector2(460,300);
            var shade=settings.AddComponent<Image>(); shade.color=new Color(.025f,.045f,.05f,.98f);
            languageLabel=Button(settings.transform,"Idioma: Português",new Vector2(40,40),new Vector2(380,50),()=>{spanish=!spanish;});
            effectsLabel=Button(settings.transform,"Reduzir efeitos",new Vector2(40,110),new Vector2(380,50),()=>{reduced=!reduced;vignette.enabled=!reduced;});
            Button(settings.transform,"Continuar",new Vector2(40,180),new Vector2(380,50),ToggleSettings);
            settings.SetActive(false); Resize();
            rewards=new GameObject("PortalUpgradeChoices",typeof(RectTransform));rewards.transform.SetParent(safe,false);
            var rewardRect=(RectTransform)rewards.transform;rewardRect.anchorMin=rewardRect.anchorMax=new Vector2(.5f,.5f);rewardRect.pivot=Vector2.one*.5f;rewardRect.sizeDelta=new Vector2(460,300);
            rewards.AddComponent<Image>().color=new Color(.025f,.045f,.05f,.98f);
            Button(rewards.transform,"Restaurar vida",new Vector2(40,40),new Vector2(380,50),()=>RewardSelected(0));
            agileLabel=Button(rewards.transform,"Mãos ágeis",new Vector2(40,110),new Vector2(380,50),()=>RewardSelected(1));
            damageLabel=Button(rewards.transform,"Machado forte",new Vector2(40,180),new Vector2(380,50),()=>RewardSelected(2));
            rewards.SetActive(false);
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
            var ring=Node<FrameGraphic>(safe,action,at,size);ring.Circle=true;ring.color=new Color(.8f,.9f,.86f,.38f);
            var touch=ring.gameObject.AddComponent<TouchBinding>();touch.Input=Input;touch.Action=action;
            var icon=Node<ControlIcon>(ring.transform,"Icon",Vector2.zero,size);icon.Action=action;icon.Input=Input;icon.raycastTarget=false;icon.color=new Color(.85f,.94f,.89f,.48f);
        }
        private void ToggleSettings() {if(rewards!=null&&rewards.activeSelf)return;bool pause=!settings.activeSelf;Input.Cancel();Input.Paused=pause;Time.timeScale=pause?0:1;settings.SetActive(pause);}
        private System.Action<int> rewardAction;
        public void ShowRewards(System.Action<int> choose){rewardAction=choose;Input.Cancel();Input.Paused=true;Time.timeScale=0;rewards.SetActive(true);}
        private void RewardSelected(int choice){if(rewardAction!=null)rewardAction(choice);}
        public void CloseRewards(){rewardAction=null;rewards.SetActive(false);Input.Cancel();Input.Paused=false;Time.timeScale=1;}
        private void Resize()
        {
            Input.Cancel(); // Releases touch owners before applying the new safe area.
            Rect area=Screen.safeArea;lastArea=area;lastScreen=new Vector2(Screen.width,Screen.height);
            safe.anchorMin=new Vector2(area.xMin/Screen.width,area.yMin/Screen.height);safe.anchorMax=new Vector2(area.xMax/Screen.width,area.yMax/Screen.height);safe.offsetMin=safe.offsetMax=Vector2.zero;
        }
        private void Update()
        {
            if(Player==null) return;
            languageLabel.text=spanish?"Idioma: Español":"Idioma: Português";
            effectsLabel.text=reduced?(spanish?"Restaurar efectos":"Restaurar efeitos"):(spanish?"Reducir efectos":"Reduzir efeitos");
            agileLabel.text=spanish?"Manos ágiles":"Mãos ágeis";damageLabel.text=spanish?"Hacha fuerte":"Machado forte";
            if(Screen.safeArea!=lastArea || lastScreen!=new Vector2(Screen.width,Screen.height)) Resize();
            float hp=Player.Rules.Health;if(hp>previous)healNotice=1.2f;previous=hp;healNotice=Mathf.Max(0,healNotice-Time.unscaledDeltaTime);
            health.rectTransform.sizeDelta=new Vector2(286*Mathf.Clamp01(hp/Player.Rules.MaxHealth),14);
            health.color=hp/Player.Rules.MaxHealth<=.3f?new Color(.95f,.32f,.2f):new Color(.87f,.73f,.3f);
            life.text="Vida "+hp.ToString("0.#")+" / "+Player.Rules.MaxHealth.ToString("0.#");
            healed.text=healNotice>0?"Vida restaurada":"";
            status.text=Player.Rules.Dead?(spanish?"Derrotado — reinicia la sala en Unity":"Derrotado — reinicie a sala no Unity"):(spanish?"ESTUDIO UNITY · arte de transición\nDerrota a los enemigos y alcanza el portal":"ESTUDO UNITY · arte de transição\nDerrote os inimigos e alcance o portal");
            if(Keyboard.current!=null && Keyboard.current.escapeKey.wasPressedThisFrame) ToggleSettings();
        }
    }
}
