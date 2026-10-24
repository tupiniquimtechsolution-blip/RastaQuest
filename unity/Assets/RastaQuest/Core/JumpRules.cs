using System;

namespace RastaQuest.Core
{
    public sealed class JumpRules
    {
        public const float CoyoteTime = .10f, BufferTime = .12f;
        public int Used { get; private set; }
        private float coyote, buffer;
        public void Press() { buffer = BufferTime; }
        public void Cancel() { buffer = 0; }
        public void Step(float delta, bool grounded)
        {
            if (delta < 0 || float.IsNaN(delta) || float.IsInfinity(delta))
                throw new ArgumentOutOfRangeException("delta");
            if (grounded) { coyote = CoyoteTime; Used = 0; }
            else coyote = Math.Max(0, coyote-delta);
            buffer = Math.Max(0, buffer-delta);
        }
        public float ConsumeVelocity()
        {
            if (buffer <= 0 || (coyote <= 0 && Used >= 2)) return 0;
            if (coyote <= 0 && Used == 0) Used = 1;
            float value = Used == 0 ? 8.75f : 8.75f*.94f;
            Used++; buffer = 0; coyote = 0; return value;
        }
    }
}
