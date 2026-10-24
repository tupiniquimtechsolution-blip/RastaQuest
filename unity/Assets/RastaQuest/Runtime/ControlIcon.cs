using UnityEngine;
using UnityEngine.UI;

namespace RastaQuest.Unity
{
    public sealed class ControlIcon : MaskableGraphic
    {
        public string Action;
        public SliceInput Input;
        private void Update() {if(Action=="stick")SetVerticesDirty();}
        protected override void OnPopulateMesh(VertexHelper vh)
        {
            vh.Clear();Vector2 c=rectTransform.rect.center;float s=rectTransform.rect.width;
            if(Action=="stick")
            {
                c+=Input.Stick*s*.22f;
                for(int i=0;i<24;i++){float a=i*Mathf.PI/12,b=(i+1)*Mathf.PI/12;Tri(vh,c,c+new Vector2(Mathf.Cos(a),Mathf.Sin(a))*s*.14f,c+new Vector2(Mathf.Cos(b),Mathf.Sin(b))*s*.14f);}
            }
            else if(Action=="jump")
            {
                Tri(vh,c+new Vector2(-s*.18f,0),c+new Vector2(0,s*.22f),c+new Vector2(s*.18f,0));
                Quad(vh,c+new Vector2(-s*.05f,-s*.18f),new Vector2(s*.1f,s*.23f));
            }
            else if(Action=="attack")
            {
                Quad(vh,c+new Vector2(-s*.025f,-s*.24f),new Vector2(s*.05f,s*.45f));
                Tri(vh,c+new Vector2(-s*.22f,s*.21f),c+new Vector2(-s*.22f,-s*.03f),c+new Vector2(0,s*.09f));
                Tri(vh,c+new Vector2(s*.22f,s*.21f),c+new Vector2(0,s*.09f),c+new Vector2(s*.22f,-s*.03f));
            }
            else
            {
                Tri(vh,c+new Vector2(-s*.18f,s*.2f),c+new Vector2(s*.18f,s*.2f),c+new Vector2(0,-s*.22f));
            }
        }
        private void Tri(VertexHelper vh,Vector2 a,Vector2 b,Vector2 c){int n=vh.currentVertCount;vh.AddVert(a,color,Vector2.zero);vh.AddVert(b,color,Vector2.zero);vh.AddVert(c,color,Vector2.zero);vh.AddTriangle(n,n+1,n+2);}
        private void Quad(VertexHelper vh,Vector2 at,Vector2 size){Tri(vh,at,at+Vector2.right*size.x,at+size);Tri(vh,at,at+size,at+Vector2.up*size.y);}
    }
}
