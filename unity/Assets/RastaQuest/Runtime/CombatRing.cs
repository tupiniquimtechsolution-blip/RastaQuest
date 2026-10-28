using UnityEngine;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class CombatRing : MonoBehaviour
    {
        public SlicePlayer Player;
        public SliceEnemy Enemy;
        private LineRenderer line;
        private Material material;
        private void Start()
        {
            line=gameObject.AddComponent<LineRenderer>();line.useWorldSpace=false;line.loop=true;line.positionCount=48;line.widthMultiplier=.027f;line.sortingOrder=25;
            material=new Material(Shader.Find("Sprites/Default"));line.sharedMaterial=material;
            float radius = Player != null ? .58f : .40f;
            for(int i=0;i<48;i++){float a=i*Mathf.PI/24;line.SetPosition(i,new Vector3(Mathf.Cos(a)*radius,Mathf.Sin(a)*radius+(Player!=null?0:.7f),0));}
        }
        private void LateUpdate()
        {
            if(line==null)return;line.enabled=Player!=null?Player.Rules.Guarding:Enemy!=null&&Enemy.Alive&&Enemy.Telling;
            Color color=Player!=null?(Player.Rules.GuardAge<=CombatRules.PerfectWindow?new Color(.35f,.95f,1,.7f):new Color(.7f,.9f,1,.45f)):new Color(1,.7f,.2f,.8f);
            line.startColor=line.endColor=color;
        }
        private void OnDestroy(){if(material!=null)Destroy(material);}
    }
}
