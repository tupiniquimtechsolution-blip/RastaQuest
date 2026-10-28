using System;

namespace RastaQuest.Core
{
    public sealed class StickRules
    {
        public float X { get; private set; }
        public float Y { get; private set; }
        public float Horizontal { get { return Math.Abs(X) > .18f ? X : 0; } }
        private bool up;
        // Local points are relative to the RectTransform pivot, not necessarily its center.
        public bool Point(float x, float y, float centerX, float centerY, float radius)
        {
            if (radius <= 0 || float.IsNaN(radius) || float.IsInfinity(radius)) throw new ArgumentOutOfRangeException("radius");
            return Set((x-centerX)/radius, (y-centerY)/radius);
        }
        public bool Set(float x, float y)
        {
            if (float.IsNaN(x) || float.IsInfinity(x) || float.IsNaN(y) || float.IsInfinity(y))
                throw new ArgumentOutOfRangeException("axis");
            double length = Math.Sqrt((double)x*x+(double)y*y);
            X = (float)(x/Math.Max(1,length)); Y = (float)(y/Math.Max(1,length));
            bool jump = Y > .65f && !up;
            if (jump) up = true;
            if (Y < .35f) up = false;
            return jump;
        }
        public void Reset() { X = Y = 0; up = false; }
    }
}
