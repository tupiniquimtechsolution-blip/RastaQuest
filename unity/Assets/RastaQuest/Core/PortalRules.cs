using System;

namespace RastaQuest.Core
{
    public enum RoomPhase { Encounter, Rewards, Ready, Transition, Defeated }
    public enum PortalReward { RestoreHealth, QuickHands, StrongAxe }

    // One offer, one choice and one transition per cleared room. Pause preserves the phase.
    public sealed class PortalRules
    {
        public const float TransitionSeconds = .45f;
        public RoomPhase Phase { get; private set; }
        public bool Paused { get; private set; }
        public int Biome { get; private set; }
        public PortalReward? Reward { get; private set; }
        public float TransitionRemaining { get; private set; }
        private readonly int worlds;

        public PortalRules(int worldCount)
        {
            if (worldCount < 1) throw new ArgumentOutOfRangeException("worldCount");
            worlds = worldCount;
        }
        public bool Offer(bool enemiesAlive, bool playerAlive)
        {
            if (Paused || Phase != RoomPhase.Encounter || enemiesAlive || !playerAlive) return false;
            Phase = RoomPhase.Rewards; return true;
        }
        public bool Choose(int choice)
        {
            if (Paused || Phase != RoomPhase.Rewards || choice < 0 || choice > 2) return false;
            Reward = (PortalReward)choice; Phase = RoomPhase.Ready; return true;
        }
        public bool Enter(bool inRange, bool playerAlive)
        {
            if (Paused || Phase != RoomPhase.Ready || !inRange || !playerAlive) return false;
            Phase = RoomPhase.Transition; TransitionRemaining = TransitionSeconds; return true;
        }
        public bool Step(float delta, out bool restoreHealth)
        {
            if (delta < 0 || float.IsNaN(delta) || float.IsInfinity(delta)) throw new ArgumentOutOfRangeException("delta");
            restoreHealth = false;
            if (Paused || Phase != RoomPhase.Transition) return false;
            TransitionRemaining = Math.Max(0, TransitionRemaining-delta);
            if (TransitionRemaining > 0) return false;
            restoreHealth = Reward == PortalReward.RestoreHealth;
            Biome = (Biome+1)%worlds; Reward = null; Phase = RoomPhase.Encounter; return true;
        }
        public void Pause() { if (Phase != RoomPhase.Defeated) Paused = true; }
        public void Resume() { Paused = false; }
        public void Defeat() { Phase = RoomPhase.Defeated; Paused = false; Reward = null; TransitionRemaining = 0; }
        public void Restart() { Phase = RoomPhase.Encounter; Paused = false; Biome = 0; Reward = null; TransitionRemaining = 0; }
    }
}
