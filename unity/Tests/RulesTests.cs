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
        var guard = new CombatRules(5); guard.RaiseGuard(); guard.Step(.3f);
        guard.Receive(1,HitKind.Melee);
        Check(guard.Receive(1,HitKind.Projectile)==DefenseResult.Reflected && guard.Health==4.5f,"reflect during damage immunity");
        guard.ReleaseGuard();guard.Step(1);guard.Receive(float.NaN,HitKind.Area);guard.Receive(float.PositiveInfinity,HitKind.Area);
        Check(guard.Health==4.5f,"invalid damage cannot poison health");
        guard.Receive(99,HitKind.Area);Check(guard.Dead&&guard.Restore()==0&&!guard.RequestAttack()&&!guard.RaiseGuard(),"death requires restart, not reward revive");

        var stick = new StickRules();
        Check(!stick.Point(75,-75,75,-75,75)&&stick.Horizontal==0&&stick.Y==0,"center of top-left-pivot stick is neutral");
        stick.Point(150,-75,75,-75,75);Check(stick.Horizontal==1&&stick.Y==0,"right edge");
        stick.Point(0,-75,75,-75,75);Check(stick.Horizontal==-1&&stick.Y==0,"left edge");
        Check(stick.Point(75,0,75,-75,75),"up gesture jumps");
        Check(!stick.Point(75,0,75,-75,75),"held up never repeats jump");
        Check(!stick.Set(0,.5f)&&!stick.Set(0,.7f),"hysteresis prevents jitter jump");
        stick.Set(0,.2f);Check(stick.Set(0,.8f),"neutral rearms up gesture");
        stick.Set(.1f,0);Check(stick.Horizontal==0,"horizontal dead zone");
        stick.Set(4,4);Check(Math.Abs(stick.X*stick.X+stick.Y*stick.Y-1)<.001f,"diagonal normalized");
        stick.Reset();Check(stick.Horizontal==0&&stick.Y==0&&stick.Set(0,1),"cancel releases held up");
        bool badRadius=false;try{stick.Point(0,0,0,0,0);}catch(ArgumentOutOfRangeException){badRadius=true;}Check(badRadius,"reject zero stick radius");

        var portal = new PortalRules(3);bool heal;
        Check(!portal.Choose(0)&&!portal.Enter(true,true),"cannot choose or enter before clear");
        Check(!portal.Offer(true,true)&&!portal.Offer(false,false),"enemy or death blocks offer");
        portal.Pause();Check(!portal.Offer(false,true),"pause blocks reward offer");portal.Resume();
        Check(portal.Offer(false,true)&&!portal.Offer(false,true),"one offer per clear");
        Check(!portal.Choose(-1)&&!portal.Choose(3)&&portal.Phase==RoomPhase.Rewards,"invalid reward leaves offer intact");
        portal.Pause();Check(!portal.Choose(0)&&portal.Phase==RoomPhase.Rewards,"suspend preserves pending choices");portal.Resume();
        Check(portal.Choose(0)&&!portal.Choose(2),"double click cannot stack rewards");
        Check(!portal.Enter(false,true)&&!portal.Enter(true,false),"distance and living player required");
        Check(portal.Enter(true,true)&&!portal.Enter(true,true),"enter exactly once");
        portal.Step(.2f,out heal);float remaining=portal.TransitionRemaining;portal.Pause();
        Check(!portal.Step(10,out heal)&&!heal&&portal.TransitionRemaining==remaining,"background pause freezes portal");portal.Resume();
        Check(portal.Step(.3f,out heal)&&heal&&portal.Biome==1&&portal.Phase==RoomPhase.Encounter,"selected restoration delivered at destination");
        Check(!portal.Step(10,out heal)&&!heal,"restoration not applied twice");
        for(int choice=1;choice<=2;choice++)
        {
            portal.Offer(false,true);portal.Choose(choice);portal.Enter(true,true);
            Check(portal.Step(.5f,out heal)&&!heal,"non-healing reward never restores life: "+choice);
        }
        Check(portal.Biome==0,"three biomes wrap correctly");
        portal.Offer(false,true);portal.Choose(0);portal.Enter(true,true);portal.Defeat();
        Check(!portal.Step(1,out heal)&&!heal&&portal.Reward==null,"death discards pending transition reward");
        portal.Pause();Check(!portal.Paused&&!portal.Offer(false,true),"defeat cannot become resumable pause");
        portal.Restart();Check(portal.Phase==RoomPhase.Encounter&&portal.Biome==0&&!portal.Paused&&portal.Reward==null,"restart clears flow state");
        bool badDelta=false;try{portal.Step(float.PositiveInfinity,out heal);}catch(ArgumentOutOfRangeException){badDelta=true;}Check(badDelta,"invalid portal timestep rejected");
        foreach(ReviewLabel key in Enum.GetValues(typeof(ReviewLabel)))
            Check(!String.IsNullOrWhiteSpace(ReviewText.Get(key,false))&&!String.IsNullOrWhiteSpace(ReviewText.Get(key,true)),"both languages present: "+key);
        Check(ReviewText.Get(ReviewLabel.Encounter,true).Contains("Derrota")&&ReviewText.Get(ReviewLabel.Restart,true)=="Volver a intentar","Spanish gameplay and restart labels");
        Console.WriteLine("RQ_UNITY_CORE_OK " + count + " assertions; Unity runtime NOT tested"); return 0;
    }
}
