using UnityEngine;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class SliceBootstrap : MonoBehaviour
    {
        public static Sprite WhiteSprite;
        public SlicePlayer Player { get; private set; }
        public SliceHud Hud { get; private set; }
        private Transform room;
        private SpriteRenderer portal;
        private int biome;
        private bool entering;
        private bool rewardOffered, rewardChosen, pendingHeal;
        private float transition;
        private Camera cameraView;
        private float cameraVelocity;
        private readonly string[] worlds={"forest","castle","caves"};
        private void Start()
        {
            ReviewArt.Load(); Application.targetFrameRate=60;Time.fixedDeltaTime=1f/60;
            Screen.autorotateToPortrait=false;Screen.autorotateToPortraitUpsideDown=false;
            Screen.autorotateToLandscapeLeft=true;Screen.autorotateToLandscapeRight=true;Screen.orientation=ScreenOrientation.AutoRotation;
            Physics2D.IgnoreLayerCollision(8,9,true);Physics2D.IgnoreLayerCollision(9,9,true);
            var texture=new Texture2D(1,1);texture.SetPixel(0,0,Color.white);texture.Apply();WhiteSprite=Sprite.Create(texture,new Rect(0,0,1,1),Vector2.one*.5f,1);
            cameraView=new GameObject("SideScrollingCamera").AddComponent<Camera>();cameraView.tag="MainCamera";
            cameraView.orthographic=true;cameraView.orthographicSize=5.625f;cameraView.backgroundColor=new Color(.07f,.13f,.13f);cameraView.transform.position=new Vector3(10,4.375f,-10);
            var input=gameObject.AddComponent<SliceInput>();Player=new GameObject("RastaWarrior").AddComponent<SlicePlayer>();Player.transform.position=new Vector3(4,.45f,0);Player.Input=input;input.Player=Player;
            Hud=new GameObject("PortraitHealthHud").AddComponent<SliceHud>();Hud.Initialize(Player,input);
            BuildRoom();
            if(System.Array.IndexOf(System.Environment.GetCommandLineArgs(),"--rq-probe")>=0)gameObject.AddComponent<NativeReviewProbe>();
        }
        private void BuildRoom()
        {
            rewardOffered=rewardChosen=pendingHeal=false;
            if(room!=null) Destroy(room.gameObject);foreach(var shot in FindObjectsByType<SliceShot>(FindObjectsSortMode.None))Destroy(shot.gameObject);
            room=new GameObject("PortalRegion_"+worlds[biome]).transform;
            var spec=System.Array.Find(ReviewArt.Data.environments,e=>e.key==worlds[biome]);
            var backdrop=new GameObject("ParallaxBackground").transform;backdrop.SetParent(room);
            for(int i=-1;i<5;i++){var s=Sprite("FarLayer",ReviewArt.Sprite(spec.background),new Vector2(i*20+10,4.375f),-20,backdrop);s.color=new Color(.55f,.58f,.58f);}
            var layer=backdrop.gameObject.AddComponent<ParallaxLayer>();layer.Camera=cameraView;
            Ground(new Vector2(30,-.25f),new Vector2(60,.5f));
            Ground(new Vector2(-.3f,4),new Vector2(.5f,12));Ground(new Vector2(60.3f,4),new Vector2(.5f,12));
            for(int i=0;i<120;i++)Sprite("Causeway",ReviewArt.Sprite(spec.tile),new Vector2(i*.5f+.25f,-.25f),0,room);
            Platform(9,2.1f,2.5f,spec.tile);Platform(15,3.2f,3,spec.tile);Platform(27,2.2f,3,spec.tile);
            for(int i=0;i<4;i++)
            {
                var enemy=new GameObject(i%2==0?"Chaser":"Ranged").AddComponent<SliceEnemy>();enemy.transform.SetParent(room);enemy.transform.position=new Vector2(12+i*9,.5f);enemy.Initialize(Player,i%2==1);
            }
            var portalClip=ReviewArt.Clip("portal","idle");
            portal=Sprite("Portal",portalClip!=null?ReviewArt.Sprite(portalClip.frames[0].file):WhiteSprite,new Vector2(55,1.1f),3,room);portal.transform.localScale=Vector3.one*1.15f;
            Player.Body.position=new Vector2(4,.45f);Player.Body.linearVelocity=Vector2.zero;Player.Rules.Locked=false;
        }
        private void Ground(Vector2 at,Vector2 size)
        {
            var g=new GameObject("GroundCollision");g.transform.SetParent(room);g.transform.position=at;g.AddComponent<BoxCollider2D>().size=size;
        }
        private void Platform(float x,float y,float width,string tile)
        {
            var g=new GameObject("RaisedOneWayPlatform");g.transform.SetParent(room);g.transform.position=new Vector2(x,y);
            var shape=g.AddComponent<BoxCollider2D>();shape.size=new Vector2(width,.2f);shape.usedByEffector=true;
            var effector=g.AddComponent<PlatformEffector2D>();effector.useOneWay=true;effector.useOneWayGrouping=true;effector.surfaceArc=160;
            for(float i=0;i<width;i+=.5f)Sprite("PlatformTop",ReviewArt.Sprite(tile),new Vector2(x-width*.5f+i+.25f,y-.15f),1,room);
        }
        public static SpriteRenderer Sprite(string name,Sprite image,Vector2 at,int order,Transform parent)
        {
            var s=new GameObject(name).AddComponent<SpriteRenderer>();s.transform.SetParent(parent);s.transform.position=at;s.sprite=image;s.sortingOrder=order;return s;
        }
        private void LateUpdate()
        {
            if(Player==null)return;
            float halfWidth=cameraView.orthographicSize*cameraView.aspect;
            float x=Mathf.Clamp(Player.transform.position.x+Player.Facing*1.8f,halfWidth,60-halfWidth);
            cameraView.transform.position=new Vector3(Mathf.SmoothDamp(cameraView.transform.position.x,x,ref cameraVelocity,.15f),4.375f,-10);
            bool any=false;foreach(var foe in room.GetComponentsInChildren<SliceEnemy>())if(foe.Alive)any=true;
            portal.color=any||!rewardChosen?new Color(.35f,.4f,.45f):Color.white;
            if(!any&&!rewardOffered&&!Player.Rules.Dead){rewardOffered=true;Hud.ShowRewards(ChooseReward);}
            if(!any && rewardChosen && !entering && !Player.Rules.Dead && Vector2.Distance(Player.transform.position,portal.transform.position)<1.2f)
            {entering=true;transition=.45f;Player.Input.Cancel();Player.Rules.Locked=true;}
            if(entering)
            {
                transition-=Time.deltaTime;
                if(transition<=0){entering=false;if(pendingHeal)Player.Rules.Restore();biome=(biome+1)%worlds.Length;BuildRoom();}
            }
        }
        public void ChooseReward(int choice)
        {
            if(!rewardOffered||rewardChosen||choice<0||choice>2)return;
            rewardChosen=true;pendingHeal=choice==0;
            if(choice==1)Player.Rules.Cycle=Mathf.Max(.12f,Player.Rules.Cycle-.04f);
            if(choice==2)Player.Damage+=1;
            Hud.CloseRewards();
        }
    }
    public sealed class ParallaxLayer : MonoBehaviour
    {
        public Camera Camera;
        private void LateUpdate(){transform.position=new Vector3(Camera.transform.position.x*.25f,0,0);}
    }
}
