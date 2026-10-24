using System;
using RastaQuest.Core;

public static class RulesTests
{
    private static int count;
    private static void Check(bool ok, string name) { if (!ok) throw new Exception(name); count++; }
    public static int Main()
    {
        var c = new CombatRules(5);
        Check(c.RequestAttack(), "initial attack");
        Check(!c.ClaimTarget(1), "no windup damage");
        c.Step(.06f); Check(c.Phase == AttackPhase.Active && c.ClaimTarget(1), "active damage");
        Check(!c.ClaimTarget(1) && c.ClaimTarget(2), "one hit per target, multiple targets");
        Check(!c.RaiseGuard(), "cannot cancel active into defense");
        c.Step(.16f); Check(c.Phase == AttackPhase.Recovery && c.RaiseGuard(), "recovery cancel");
        Check(c.Receive(1, HitKind.Melee) == DefenseResult.Parried && c.Health == 5, "perfect parry");
        Check(c.Receive(1, HitKind.Melee) == DefenseResult.Blocked && c.Health == 4.5f, "one perfect per press");
        c.Step(.36f); Check(c.Receive(1, HitKind.Projectile) == DefenseResult.Reflected && c.Health == 4.5f, "reflect while held");
        c.ReleaseGuard(); c.Step(.4f); c.Receive(1, HitKind.Contact);
        Check(c.Health == 3.5f, "contact damage unguarded");
        Check(c.Restore() == 1.5f && c.Restore() == 0, "bounded restoration");
        c.CancelInputs(); c.Cycle = .26f; c.RequestAttack(); c.Step(.104f);
        Check(c.Phase == AttackPhase.Active && Math.Abs(c.AttackFraction-.4f)<.001f, "scaled timing drives pose");
        c.RequestAttack(); c.Step(.157f); Check(c.Phase == AttackPhase.Windup && c.Combo == 1, "buffered combo");
        c.CancelInputs(); c.Step(1); Check(c.Phase == AttackPhase.Idle && !c.Guarding, "pause cancels buffer");
        c.RaiseGuard(); c.Step(.3f); c.RaiseGuard();
        Check(c.Receive(1, HitKind.Melee) == DefenseResult.Blocked, "holding does not refresh window");
        var j = new JumpRules(); j.Step(.02f,true); j.Press();
        Check(j.ConsumeVelocity() == 8.75f && j.Used == 1, "ground jump");
        j.Step(.02f,false); j.Press(); Check(j.ConsumeVelocity() > 8 && j.Used == 2, "double jump");
        j.Press(); Check(j.ConsumeVelocity() == 0, "no third jump");
        j.Step(.02f,true); j.Step(.11f,false); j.Press(); j.ConsumeVelocity();
        Check(j.Used == 2, "walking off leaves one air jump");
        j.Step(.02f,true); j.Press(); j.Cancel(); Check(j.ConsumeVelocity() == 0, "cancel jump input");
        bool rejected = false; try { c.Step(float.NaN); } catch (ArgumentOutOfRangeException) { rejected = true; }
        Check(rejected, "invalid timestep");
        // Contract hardening: corrupt inputs must never poison health/jump state.
        bool invalid = false;
        try { new CombatRules(float.NaN); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid, "reject NaN max health");
        invalid = false;
        try { new CombatRules(0); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid, "reject nonpositive max health");
        var robust = new CombatRules(5);
        invalid = false;
        try { robust.Receive(float.NaN, HitKind.Melee); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid && robust.Health == 5, "reject NaN damage without corrupting health");
        invalid = false;
        try { robust.Receive(-1, HitKind.Melee); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid && robust.Health == 5, "reject negative damage");
        invalid = false;
        try { robust.Receive(float.PositiveInfinity, HitKind.Melee); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid && robust.Health == 5, "reject infinite damage");
        Check(robust.Receive(0, HitKind.Melee) == DefenseResult.Damage && robust.Health == 5,
              "zero damage does not mutate health");
        robust.Cycle = float.NaN; invalid = false;
        try { robust.Step(.01f); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid && robust.Health == 5, "reject nonfinite attack cycle");
        invalid = false;
        try { j.Step(float.NaN, false); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid, "reject NaN jump step");
        invalid = false;
        try { j.Step(-.1f, true); } catch (ArgumentOutOfRangeException) { invalid = true; }
        Check(invalid, "reject negative jump step");
        var oneHit = new CombatRules(5);
        oneHit.RequestAttack(); oneHit.Step(.06f);
        Check(oneHit.ClaimTarget(42) && !oneHit.ClaimTarget(42), "one hit per actor per attack");
        oneHit.Step(.25f); oneHit.Step(.01f);
        oneHit.RequestAttack(); oneHit.Step(.06f);
        Check(oneHit.ClaimTarget(42), "next attack resets claimed targets");
        Console.WriteLine("RQ_UNITY_CORE_OK " + count + " assertions; Unity runtime NOT tested"); return 0;
    }
}
