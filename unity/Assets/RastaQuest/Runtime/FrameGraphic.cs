using UnityEngine;
using UnityEngine.UI;

namespace RastaQuest.Unity
{
    // Original code-native framing; no competitor texture is imported.
    public sealed class FrameGraphic : MaskableGraphic
    {
        public bool Vignette, Circle;
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear(); var r = GetPixelAdjustedRect();
            if (Vignette)
            {
                for (int i=0;i<48;i++)
                {
                    float a = i*Mathf.PI*2/48, b = (i+1)*Mathf.PI*2/48;
                    Vector2 center = r.center;
                    Vector2 v1 = new Vector2(Mathf.Cos(a)*r.width*.75f,Mathf.Sin(a)*r.height*.75f);
                    Vector2 v2 = new Vector2(Mathf.Cos(b)*r.width*.75f,Mathf.Sin(b)*r.height*.75f);
                    Add(vh,center+v1*.58f,center+v2*.58f,center+v2,center+v1,new Color(0,0,0,0),new Color(.015f,.025f,.028f,.70f));
                }
                return;
            }
            if (Circle)
            {
                for (int i=0;i<48;i++)
                {
                    float a = i*Mathf.PI*2/48, b=(i+1)*Mathf.PI*2/48;
                    var p = new Vector2(Mathf.Cos(a),Mathf.Sin(a)); var q = new Vector2(Mathf.Cos(b),Mathf.Sin(b));
                    Add(vh,r.center+p*(r.width*.42f),r.center+q*(r.width*.42f),r.center+q*(r.width*.48f),r.center+p*(r.width*.48f),color,color);
                }
                return;
            }
            float cut = Mathf.Min(10,r.height*.2f);
            Vector2[] points = {new Vector2(r.xMin+cut,r.yMin),new Vector2(r.xMax-cut,r.yMin),new Vector2(r.xMax,r.yMin+cut),new Vector2(r.xMax,r.yMax-cut),new Vector2(r.xMax-cut,r.yMax),new Vector2(r.xMin+cut,r.yMax),new Vector2(r.xMin,r.yMax-cut),new Vector2(r.xMin,r.yMin+cut)};
            for (int i=0;i<8;i++)
            {
                var p=points[i]; var q=points[(i+1)%8]; var inset=(r.center-p).normalized*3; var insetQ=(r.center-q).normalized*3;
                Add(vh,p+inset,q+insetQ,q,p,color,color);
            }
        }
        private static void Add(VertexHelper vh, Vector2 a, Vector2 b, Vector2 c, Vector2 d, Color inner, Color outer)
        {
            int n=vh.currentVertCount; vh.AddVert(a,inner,Vector2.zero); vh.AddVert(b,inner,Vector2.zero); vh.AddVert(c,outer,Vector2.zero); vh.AddVert(d,outer,Vector2.zero);
            vh.AddTriangle(n,n+1,n+2); vh.AddTriangle(n,n+2,n+3);
        }
    }
}
