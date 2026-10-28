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
        private ClipPlayer portalArt;
        public readonly PortalRules Flow = new PortalRules(3);
        private SliceInput input;
        private float defeatDelay;
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
            input=gameObject.AddComponent<SliceInput>(); CreatePlayer();
            Hud=new GameObject("PortraitHealthHud").AddComponent<SliceHud>();Hud.Initialize(Player,input,this);
            BuildRoom();
            if(System.Array.IndexOf(System.Environment.GetCommandLineArgs(),"--rq-probe")>=0)gameObject.AddComponent<NativeReviewProbe>();
        }
        private void BuildRoom()
        {
            if(room!=null) {room.gameObject.SetActive(false);Destroy(room.gameObject);}
            foreach(var shot in FindObjectsByType<SliceShot>(FindObjectsSortMode.None)){shot.gameObject.SetActive(false);Destroy(shot.gameObject);}
            room=new GameObject("PortalRegion_"+worlds[Flow.Biome]).transform;
            var spec=System.Array.Find(ReviewArt.Data.environments,e=>e.key==worlds[Flow.Biome]);
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
            portalArt=new GameObject("Portal").AddComponent<ClipPlayer>();portalArt.transform.SetParent(room);
            portalArt.transform.position=new Vector2(55,1.1f);portalArt.RenderScale=1.15f;portalArt.Initialize("portal");
            portal=portalArt.Body;portal.sortingOrder=3;portalArt.Pose("idle",1,0);
            Player.Body.position=new Vector2(4,.45f);Player.Body.linearVelocity=Vector2.zero;Player.Rules.Locked=false;
            cameraVelocity=0;
            cameraView.transform.position=new Vector3(cameraView.orthographicSize*cameraView.aspect,4.375f,-10);
        }
        private void CreatePlayer()
        {
            Player=new GameObject("RastaWarrior").AddComponent<SlicePlayer>();
            Player.transform.position=new Vector3(4,.45f,0);Player.Input=input;input.Player=Player;
        }
        public void RestartRun()
        {
            if(Flow.Phase!=RoomPhase.Defeated)return;
            input.Cancel(); Player.gameObject.SetActive(false); Destroy(Player.gameObject);
            Flow.Restart(); defeatDelay=0; CreatePlayer(); BuildRoom(); Hud.Rebind(Player);
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
            if(Player==null||Flow.Paused)return;
            portalArt.Pose("idle",1,Time.deltaTime);
            float halfWidth=cameraView.orthographicSize*cameraView.aspect;
            float x=Mathf.Clamp(Player.transform.position.x+Player.Facing*1.8f,halfWidth,60-halfWidth);
            cameraView.transform.position=new Vector3(Mathf.SmoothDamp(cameraView.transform.position.x,x,ref cameraVelocity,.15f),4.375f,-10);
            if(Player.Rules.Dead)
            {
                defeatDelay+=Time.deltaTime;
                if(defeatDelay>=.55f&&Flow.Phase!=RoomPhase.Defeated){Flow.Defeat();Hud.RefreshMode();}
                return;
            }
            bool any=false;foreach(var foe in room.GetComponentsInChildren<SliceEnemy>())if(foe.Alive)any=true;
            portal.color=Flow.Phase==RoomPhase.Ready?Color.white:new Color(.35f,.4f,.45f);
            if(Flow.Offer(any,true))Hud.RefreshMode();
            if(Flow.Enter(Vector2.Distance(Player.transform.position,portal.transform.position)<1.2f,true))
            {Player.Input.Cancel();Player.Rules.Locked=true;Hud.RefreshMode();}
            bool restore;
            if(Flow.Step(Time.deltaTime,out restore))
            {if(restore)Player.Rules.Restore();BuildRoom();Hud.RefreshMode();}
        }
        public void ChooseReward(int choice)
        {
            if(Player.Rules.Dead||!Flow.Choose(choice))return;
            if(choice==1)Player.Rules.Cycle=Mathf.Max(.12f,Player.Rules.Cycle-.04f);
            if(choice==2)Player.Damage+=1;
            Hud.RefreshMode();
        }
    }
    public sealed class ParallaxLayer : MonoBehaviour
    {
        public Camera Camera;
        private void LateUpdate(){transform.position=new Vector3(Camera.transform.position.x*.25f,0,0);}
    }
}
