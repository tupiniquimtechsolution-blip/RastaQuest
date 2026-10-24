using UnityEngine;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class SliceEnemy : MonoBehaviour
    {
        public SlicePlayer Target;
        public bool Ranged;
        public float Health = 3;
        public bool Alive { get { return Health > 0; } }
        public bool Telling { get { return windup > 0; } }
        public float TellFraction { get { return 1-windup/.6f; } }
        private Rigidbody2D body;
        private ClipPlayer art;
        private float windup, cooldown = .6f, stagger, deathTime, active;
        private int facing = -1;
        public void Initialize(SlicePlayer target, bool ranged)
        {
            Target = target; Ranged = ranged; gameObject.layer = 9;
            body = gameObject.AddComponent<Rigidbody2D>(); body.freezeRotation = true; body.gravityScale = 2.4f;
            body.interpolation = RigidbodyInterpolation2D.Interpolate;
            var collider = gameObject.AddComponent<CapsuleCollider2D>(); collider.size = new Vector2(.45f,.9f);
            var visual = new GameObject("TransitionalReviewArt"); visual.transform.SetParent(transform,false);
            art = visual.AddComponent<ClipPlayer>(); art.Initialize(ranged ? "ranged" : "chaser");
            gameObject.AddComponent<CombatRing>().Enemy = this;
        }
        private void FixedUpdate()
        {
            if (!Alive || Target == null) return;
            if (Target.Rules.Dead || Target.Rules.Locked) { body.linearVelocity = new Vector2(0,body.linearVelocity.y); return; }
            float dt = Time.fixedDeltaTime; cooldown = Mathf.Max(0,cooldown-dt);active=Mathf.Max(0,active-dt);
            if (stagger > 0) { stagger -= dt; return; }
            var delta = Target.transform.position-transform.position;
            facing = delta.x >= 0 ? 1 : -1;
            if (windup > 0)
            {
                windup -= dt; body.linearVelocity = new Vector2(0,body.linearVelocity.y);
                if (windup <= 0)
                {
                    if (Ranged) SliceShot.Fire(this,Target);
                    else if (Mathf.Abs(delta.x)<1.2f && Mathf.Abs(delta.y)<.9f) Target.Receive(1,HitKind.Melee,this);
                    cooldown = 1.1f;
                    active = .16f;
                }
            }
            else
            {
                float reach = Ranged ? 6 : .9f;
                body.linearVelocity = new Vector2(active<=0&&Mathf.Abs(delta.x)>reach ? facing*1.5f : 0,body.linearVelocity.y);
                if (Mathf.Abs(delta.x)<=reach && Mathf.Abs(delta.y)<1 && cooldown<=0) windup = .6f;
            }
            if (Mathf.Abs(delta.x)<.48f && Mathf.Abs(delta.y)<.8f)
            {
                Target.Receive(1,HitKind.Contact,this);
                Target.Body.linearVelocity = new Vector2(facing*3.28f,Target.Body.linearVelocity.y);
                body.position += Vector2.left*facing*.025f;
            }
        }
        private void Update()
        {
            if (art == null) return;
            string clip = !Alive ? "death" : stagger>0 ? "hurt" : Telling ? "tell" : active>0 ? "attack" : Mathf.Abs(body.linearVelocity.x)>.1f ? "move" : "idle";
            if (!Alive) { deathTime += Time.deltaTime; if (deathTime>.6f) Destroy(gameObject); }
            art.Pose(clip,facing,Time.deltaTime,!Alive ? Mathf.Clamp01(deathTime/.4f) : -1);
        }
        public void Damage(float amount, float push)
        {
            if (!Alive) return;
            Health = Mathf.Max(0,Health-amount); windup = 0; stagger = .25f;
            body.linearVelocity = new Vector2(push,body.linearVelocity.y);
            if (!Alive) { GetComponent<Collider2D>().enabled = false; body.simulated = false; }
        }
    }

    public sealed class SliceShot : MonoBehaviour
    {
        private SliceEnemy owner;
        private SlicePlayer target;
        private Vector2 velocity;
        private bool returned;
        private float life = 1.5f;
        public static void Fire(SliceEnemy owner, SlicePlayer target)
        {
            var shot = new GameObject("ReflectableShot").AddComponent<SliceShot>();
            shot.owner = owner; shot.target = target; shot.transform.position = owner.transform.position;
            shot.velocity = ((Vector2)(target.transform.position-owner.transform.position)).normalized*6;
            var art = shot.gameObject.AddComponent<SpriteRenderer>(); art.sortingOrder = 15;
            var clip = ReviewArt.Clip("effect","hostile_projectile");
            if (clip != null) art.sprite = ReviewArt.Sprite(clip.frames[0].file);
            else art.sprite = SliceBootstrap.WhiteSprite;
            shot.transform.localScale = Vector3.one*.18f;
        }
        private void Update()
        {
            life -= Time.deltaTime; if (life <= 0) { Destroy(gameObject); return; }
            Vector2 from = transform.position, to = from+velocity*Time.deltaTime;
            var hit = Physics2D.CircleCast(from,.14f,velocity.normalized,Vector2.Distance(from,to),(returned ? 1<<9 : 1<<8)|1);
            if (hit.collider != null)
            {
                if(hit.collider.gameObject.layer==0){Destroy(gameObject);return;}
                if (returned)
                {
                    var foe = hit.collider.GetComponent<SliceEnemy>(); if (foe != null) foe.Damage(1,Mathf.Sign(velocity.x)*2);
                }
                else if (target.Receive(1,HitKind.Projectile,owner) == DefenseResult.Reflected)
                {
                    returned = true; life = 1.5f;
                    velocity = owner != null ? ((Vector2)(owner.transform.position-transform.position)).normalized*9.375f : -velocity;
                    return;
                }
                Destroy(gameObject); return;
            }
            transform.position = to;
        }
    }
}
