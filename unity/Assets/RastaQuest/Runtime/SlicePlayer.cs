using UnityEngine;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class SlicePlayer : MonoBehaviour
    {
        public readonly CombatRules Rules = new CombatRules(5);
        public readonly JumpRules Jumps = new JumpRules();
        public SliceInput Input;
        public int Facing = 1;
        public float Damage = 1;
        public Rigidbody2D Body;
        private ClipPlayer art;
        private float hurt, guardPending, deathAge;
        private bool wasGuarding;
        private void Awake()
        {
            gameObject.layer = 8;
            Body = gameObject.AddComponent<Rigidbody2D>(); Body.freezeRotation = true;
            Body.gravityScale = 0; Body.interpolation = RigidbodyInterpolation2D.Interpolate;
            Body.collisionDetectionMode = CollisionDetectionMode2D.Continuous;
            var collider = gameObject.AddComponent<CapsuleCollider2D>(); collider.size = new Vector2(.375f,.8125f);
            var visual = new GameObject("TransitionalReviewArt"); visual.transform.SetParent(transform,false);
            visual.transform.localPosition = new Vector3(0,.06f,0);
            art = visual.AddComponent<ClipPlayer>(); art.Initialize("player");
            gameObject.AddComponent<CombatRing>().Player = this;
        }
        private void Update()
        {
            if (Input == null || Time.timeScale == 0) return;
            float dt = Time.deltaTime; Rules.Step(dt); hurt = Mathf.Max(0,hurt-dt);
            bool grounded = Physics2D.OverlapBox((Vector2)transform.position+Vector2.down*.42f,new Vector2(.31f,.06f),0,1) != null;
            Jumps.Step(dt,grounded);
            if (Input.TakeJump() && !Rules.Dead && !Rules.Locked && hurt <= 0) Jumps.Press();
            if (Input.TakeAttack() && hurt <= 0) Rules.RequestAttack();
            if (Input.Guard && !wasGuarding) guardPending = .20f;
            wasGuarding = Input.Guard;
            guardPending = Mathf.Max(0,guardPending-dt);
            if (!Input.Guard) { Rules.ReleaseGuard(); guardPending = 0; }
            else if (guardPending > 0 && hurt <= 0 && Rules.RaiseGuard()) guardPending = 0;
            string clip = Rules.Dead ? "death" : hurt > 0 ? "hurt" : Rules.Locked ? "portal_enter" :
                Rules.Phase != AttackPhase.Idle ? (grounded ? new[]{"attack_axe","attack_axe_2","attack_axe_3"}[Rules.Combo] : "attack_axe_air") :
                !grounded ? (Body.linearVelocity.y>0 ? "jump" : "fall") : Mathf.Abs(Body.linearVelocity.x)>.1f ? "run" : "idle";
            if (Rules.Dead) deathAge += dt;
            art.Pose(clip,Facing,dt,Rules.Phase != AttackPhase.Idle ? Rules.AttackFraction : Rules.Dead ? Mathf.Min(1,deathAge/.5f) : -1);
            if (Rules.Phase == AttackPhase.Active)
            {
                var center = (Vector2)transform.position+new Vector2(Facing*.6f,.1f);
                foreach (var hit in Physics2D.OverlapBoxAll(center,new Vector2(.9f,.85f),0,1<<9))
                {
                    var foe = hit.GetComponent<SliceEnemy>();
                    if (foe != null && Rules.ClaimTarget(foe.GetInstanceID())) foe.Damage(Damage,Facing*1.5f);
                }
            }
            if (transform.position.y < -6 && !Rules.Dead) Rules.Receive(100,HitKind.Area);
        }
        private void FixedUpdate()
        {
            if (Input == null) return;
            if (Rules.Dead || Rules.Locked) { Body.linearVelocity = Vector2.zero; return; }
            var velocity = Body.linearVelocity;
            float axis = hurt > 0 || Rules.Guarding ? 0 : Input.Horizontal;
            velocity.x = Mathf.MoveTowards(velocity.x,axis*4.0625f,(Mathf.Abs(axis)>.01f ? 28.125f : 34.375f)*Time.fixedDeltaTime);
            float jump = Jumps.ConsumeVelocity(); if (jump > 0) velocity.y = jump;
            velocity.y = Mathf.Max(-14.0625f,velocity.y-23.4375f*Time.fixedDeltaTime);
            Body.linearVelocity = velocity;
            if (Rules.Phase == AttackPhase.Idle && Mathf.Abs(axis)>.1f) Facing = axis > 0 ? 1 : -1;
        }
        public DefenseResult Receive(float amount, HitKind kind, SliceEnemy source)
        {
            float before = Rules.Health; var result = Rules.Receive(amount,kind);
            if (result == DefenseResult.Parried && source != null) source.Damage(Damage*CombatRules.CounterDamage,Mathf.Sign(source.transform.position.x-transform.position.x)*5.625f);
            if (Rules.Health < before) { hurt = .18f; Rules.CancelAttack(); }
            return result;
        }
        public void CancelInputs() { Rules.CancelInputs(); Jumps.Cancel(); guardPending = 0; wasGuarding = false; }
        private void OnApplicationFocus(bool focus) { if (!focus) CancelInputs(); }
    }
}
