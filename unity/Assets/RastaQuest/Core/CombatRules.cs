using System;
using System.Collections.Generic;

namespace RastaQuest.Core
{
    // Pure rules. Time is supplied by the adapter; never driven by animation events.
    public enum AttackPhase { Idle, Windup, Active, Recovery }
    public enum HitKind { Melee, Projectile, Contact, Area }
    public enum DefenseResult { Damage, Blocked, Parried, Reflected }

    public sealed class CombatRules
    {
        public const float Windup = .05f, Active = .16f, Recovery = .09f;
        public const float PerfectWindow = .28f, CounterDamage = .5f;
        public AttackPhase Phase { get; private set; }
        public int Combo { get; private set; }
        public int AttackId { get; private set; }
        public bool Guarding { get; private set; }
        public float AttackTime { get; private set; }
        public float Cycle = .30f;
        public float GuardAge { get; private set; }
        public float Health { get; private set; }
        public float MaxHealth { get; private set; }
        public bool Dead { get { return Health <= 0; } }
        public bool Locked;
        private float cooldown, comboGrace, buffer, invulnerability, counterCooldown;
        private bool spent;
        private readonly HashSet<int> hitTargets = new HashSet<int>();

        public CombatRules(float maxHealth) { MaxHealth = maxHealth; Health = maxHealth; }
        public bool RequestAttack()
        {
            if (Dead || Locked || Guarding) return false;
            if (Phase == AttackPhase.Idle && cooldown <= 0) { StartAttack(); return true; }
            if (Phase == AttackPhase.Active || Phase == AttackPhase.Recovery || Phase == AttackPhase.Idle) buffer = .18f;
            return false;
        }
        private void StartAttack()
        {
            Combo = comboGrace > 0 ? (Combo + 1) % 3 : 0;
            AttackId++; AttackTime = 0; cooldown = Cycle; Phase = AttackPhase.Windup;
            hitTargets.Clear(); buffer = 0;
        }
        public void Step(float delta)
        {
            if (delta < 0 || float.IsNaN(delta) || float.IsInfinity(delta)) throw new ArgumentOutOfRangeException("delta");
            cooldown = Math.Max(0, cooldown-delta); comboGrace = Math.Max(0, comboGrace-delta);
            invulnerability = Math.Max(0, invulnerability-delta); counterCooldown = Math.Max(0, counterCooldown-delta);
            if (Guarding) GuardAge += delta;
            if (Phase != AttackPhase.Idle)
            {
                AttackTime += delta;
                float scale = Math.Max(.4f, Math.Min(1, Cycle/(Windup+Active+Recovery)));
                if (AttackTime < Windup*scale) Phase = AttackPhase.Windup;
                else if (AttackTime < (Windup+Active)*scale) Phase = AttackPhase.Active;
                else if (AttackTime < (Windup+Active+Recovery)*scale) Phase = AttackPhase.Recovery;
                else { Phase = AttackPhase.Idle; comboGrace = .65f; }
            }
            if (buffer > 0 && Phase == AttackPhase.Idle && cooldown <= 0 && !Dead && !Locked && !Guarding) StartAttack();
            buffer = Math.Max(0, buffer-delta);
        }
        public float AttackFraction
        {
            get { return Phase == AttackPhase.Idle ? 0 : Math.Min(1, AttackTime/Math.Max(.12f, Math.Min(.30f, Cycle))); }
        }
        public bool ClaimTarget(int id) { return Phase == AttackPhase.Active && hitTargets.Add(id); }
        public bool RaiseGuard()
        {
            if (Dead || Locked || Phase == AttackPhase.Windup || Phase == AttackPhase.Active) return false;
            if (Guarding) return true; // Holding never re-arms the perfect window.
            CancelAttack(); Guarding = true; GuardAge = 0; spent = false; return true;
        }
        public void ReleaseGuard() { Guarding = false; GuardAge = 0; }
        public DefenseResult Receive(float amount, HitKind kind)
        {
            if (Dead || Locked || amount <= 0 || invulnerability > 0) return DefenseResult.Damage;
            if (Guarding)
            {
                if (kind == HitKind.Projectile) return DefenseResult.Reflected;
                if (kind == HitKind.Melee && !spent && GuardAge <= PerfectWindow && counterCooldown <= 0)
                { spent = true; counterCooldown = .22f; return DefenseResult.Parried; }
                Health = Math.Max(0, Health-amount*.5f); invulnerability = .35f;
                if (Dead) CancelInputs();
                return DefenseResult.Blocked;
            }
            Health = Math.Max(0, Health-amount); invulnerability = .35f;
            if (Dead) CancelInputs();
            return DefenseResult.Damage;
        }
        public float Restore()
        {
            if (Dead) return 0;
            float restored = MaxHealth-Health; Health = MaxHealth; return restored;
        }
        public void CancelAttack() { Phase = AttackPhase.Idle; AttackTime = 0; buffer = 0; comboGrace = 0; hitTargets.Clear(); }
        public void CancelInputs() { CancelAttack(); ReleaseGuard(); }
    }
}
