using System;
using UnityEngine;

namespace RastaQuest.Unity
{
    [Serializable] public class ReviewFrame { public string file; public float seconds; public string[] equipment; public float[] transforms; }
    [Serializable] public class ReviewClip { public string key; public ReviewFrame[] frames; }
    [Serializable] public class ReviewActor { public string key; public ReviewClip[] clips; }
    [Serializable] public class ReviewEnvironment { public string key, background, tile; }
    [Serializable] public class ReviewBridge { public bool commercialApproved; public ReviewActor[] actors; public ReviewEnvironment[] environments; }

    public static class ReviewArt
    {
        public static ReviewBridge Data;
        public static void Load()
        {
            var json = Resources.Load<TextAsset>("ReviewArt/bridge");
            if (json == null) throw new InvalidOperationException("Run tools/sync_unity_review.py before opening this project.");
            Data = JsonUtility.FromJson<ReviewBridge>(json.text);
            if (Data.commercialApproved) throw new InvalidOperationException("Review payload cannot claim commercial acceptance.");
        }
        public static Sprite Sprite(string file) { return Resources.Load<Sprite>(file); }
        public static ReviewClip Clip(string actor, string key)
        {
            foreach (var a in Data.actors) if (a.key == actor)
                foreach (var c in a.clips) if (c.key == key) return c;
            return null;
        }
    }

    public sealed class ClipPlayer : MonoBehaviour
    {
        public string Actor = "player";
        public float RenderScale = .575f;
        private SpriteRenderer body;
        private readonly SpriteRenderer[] equipment = new SpriteRenderer[2];
        private string key;
        private float elapsed;
        public SpriteRenderer Body { get { return body; } }
        public void Initialize(string actor)
        {
            Actor = actor; body = gameObject.AddComponent<SpriteRenderer>(); body.sortingOrder = 10;
            transform.localScale = Vector3.one*RenderScale;
            for (int i = 0; i < equipment.Length; i++)
            {
                var part = new GameObject("Equipment").AddComponent<SpriteRenderer>();
                part.transform.SetParent(transform, false); part.sortingOrder = 12+i; equipment[i] = part;
            }
        }
        public void Pose(string clip, int facing, float delta, float authoritativeFraction = -1)
        {
            if (key != clip) { key = clip; elapsed = 0; }
            var sequence = ReviewArt.Clip(Actor, clip);
            if (sequence == null || sequence.frames.Length == 0) return;
            float total = 0; foreach (var f in sequence.frames) total += f.seconds;
            elapsed += delta;
            float time = authoritativeFraction >= 0 ? Mathf.Clamp01(authoritativeFraction)*Mathf.Max(0,total-.0001f) : elapsed%total;
            int index = 0;
            while (index < sequence.frames.Length-1 && time >= sequence.frames[index].seconds) { time -= sequence.frames[index].seconds; index++; }
            var frame = sequence.frames[index]; body.sprite = ReviewArt.Sprite(frame.file);
            transform.localScale = new Vector3(RenderScale*facing,RenderScale,1);
            for (int i = 0; i < equipment.Length; i++)
            {
                equipment[i].enabled = frame.equipment != null && i < frame.equipment.Length;
                if (!equipment[i].enabled) continue;
                equipment[i].sprite = ReviewArt.Sprite(frame.equipment[i]);
                int offset = i*3;
                equipment[i].transform.localPosition = new Vector3(frame.transforms[offset]/64,-frame.transforms[offset+1]/64,-.01f);
                equipment[i].transform.localRotation = Quaternion.Euler(0,0,-frame.transforms[offset+2]);
            }
        }
    }
}
