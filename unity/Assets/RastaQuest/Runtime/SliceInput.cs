using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;
using RastaQuest.Core;

namespace RastaQuest.Unity
{
    public sealed class SliceInput : MonoBehaviour
    {
        public float Horizontal;
        public bool Guard;
        public Vector2 Stick;
        public bool Paused;
        private bool jump, attack;
        private readonly StickRules stickRules = new StickRules();
        public event System.Action Cancelled;
        public System.Action Backgrounded;
        public void Jump() { if (!Paused) jump = true; }
        public void Attack() { if (!Paused) attack = true; }
        public bool TakeJump() { bool result = jump; jump = false; return result; }
        public bool TakeAttack() { bool result = attack; attack = false; return result; }
        public void SetStick(Vector2 value)
        {
            if (Paused) { stickRules.Reset(); Stick = Vector2.zero; Horizontal = 0; return; }
            if (stickRules.Set(value.x,value.y)) Jump();
            Stick = new Vector2(stickRules.X,stickRules.Y); Horizontal = stickRules.Horizontal;
        }
        public void SetStickPoint(Vector2 point, Rect rect)
        {
            if (Paused) return;
            if (stickRules.Point(point.x,point.y,rect.center.x,rect.center.y,Mathf.Max(1,Mathf.Min(rect.width,rect.height)*.5f))) Jump();
            Stick = new Vector2(stickRules.X,stickRules.Y); Horizontal = stickRules.Horizontal;
        }
        public void Cancel()
        {
            Horizontal = 0; Guard = jump = attack = false; Stick = Vector2.zero; stickRules.Reset();
            if (Player != null) Player.CancelInputs();
            if (Cancelled != null) Cancelled();
        }
        public SlicePlayer Player;
        private void Update()
        {
            var key = Keyboard.current; if (key == null || Paused) return;
            float keyboard = (key.dKey.isPressed || key.rightArrowKey.isPressed ? 1 : 0)-(key.aKey.isPressed || key.leftArrowKey.isPressed ? 1 : 0);
            if (keyboard != 0 || Stick == Vector2.zero) Horizontal = keyboard;
            if (key.spaceKey.wasPressedThisFrame || key.wKey.wasPressedThisFrame || key.upArrowKey.wasPressedThisFrame) Jump();
            if (key.jKey.wasPressedThisFrame) Attack();
            if (key.kKey.wasPressedThisFrame) Guard = true;
            if (key.kKey.wasReleasedThisFrame) Guard = false;
        }
        private void Suspend() { Cancel(); if (Backgrounded != null) Backgrounded(); }
        private void OnApplicationFocus(bool focused) { if (!focused) Suspend(); }
        private void OnApplicationPause(bool paused) { if (paused) Suspend(); }
    }

    public sealed class TouchBinding : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler, IEndDragHandler
    {
        public SliceInput Input;
        public string Action;
        private int owner = int.MinValue;
        public void Bind(SliceInput input, string action)
        {
            Input=input; Action=action; Input.Cancelled+=Release;
        }
        public void OnPointerDown(PointerEventData e)
        {
            if (owner != int.MinValue || Input.Paused) return;
            owner = e.pointerId;
            if (Action == "jump") Input.Jump(); else if (Action == "attack") Input.Attack(); else if (Action == "guard") Input.Guard = true;
            else if (Action == "stick") OnDrag(e);
        }
        public void OnDrag(PointerEventData e)
        {
            if (Action != "stick" || owner != e.pointerId || Input.Paused) return;
            Vector2 point;
            var rect=(RectTransform)transform;
            if (RectTransformUtility.ScreenPointToLocalPointInRectangle(rect,e.position,e.pressEventCamera,out point))
                Input.SetStickPoint(point,rect.rect);
        }
        public void OnPointerUp(PointerEventData e) { if (owner == e.pointerId) Release(); }
        public void OnEndDrag(PointerEventData e) { OnPointerUp(e); }
        public void Release() { owner = int.MinValue; if (Action == "guard") Input.Guard = false; if (Action == "stick") Input.SetStick(Vector2.zero); }
        private void OnDisable() { if (Input != null) Release(); }
        private void OnDestroy() { if (Input != null) Input.Cancelled-=Release; }
    }
}
