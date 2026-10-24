using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.InputSystem;

namespace RastaQuest.Unity
{
    public sealed class SliceInput : MonoBehaviour
    {
        public float Horizontal;
        public bool Guard;
        public Vector2 Stick;
        public bool Paused;
        private bool jump, attack, stickUp;
        public void Jump() { if (!Paused) jump = true; }
        public void Attack() { if (!Paused) attack = true; }
        public bool TakeJump() { bool result = jump; jump = false; return result; }
        public bool TakeAttack() { bool result = attack; attack = false; return result; }
        public void SetStick(Vector2 value)
        {
            Stick = Vector2.ClampMagnitude(value,1); Horizontal = Mathf.Abs(Stick.x)>.18f ? Stick.x : 0;
            if (Stick.y>.65f && !stickUp) { Jump(); stickUp = true; }
            if (Stick.y<.35f) stickUp = false;
        }
        public void Cancel() { Horizontal = 0; Guard = jump = attack = stickUp = false; Stick = Vector2.zero; if (Player != null) Player.CancelInputs(); }
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
        private void OnApplicationFocus(bool focused) { if (!focused) Cancel(); }
        private void OnApplicationPause(bool paused) { if (paused) Cancel(); }
    }

    public sealed class TouchBinding : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler, IEndDragHandler
    {
        public SliceInput Input;
        public string Action;
        private int owner = int.MinValue;
        public void OnPointerDown(PointerEventData e)
        {
            if (owner != int.MinValue || Input.Paused) return;
            owner = e.pointerId;
            if (Action == "jump") Input.Jump(); else if (Action == "attack") Input.Attack(); else if (Action == "guard") Input.Guard = true;
            else if (Action == "stick") OnDrag(e);
        }
        public void OnDrag(PointerEventData e)
        {
            if (Action != "stick" || owner != e.pointerId) return;
            Vector2 point;
            RectTransformUtility.ScreenPointToLocalPointInRectangle((RectTransform)transform,e.position,e.pressEventCamera,out point);
            Input.SetStick(point/70);
        }
        public void OnPointerUp(PointerEventData e) { if (owner == e.pointerId) Release(); }
        public void OnEndDrag(PointerEventData e) { OnPointerUp(e); }
        public void Release() { owner = int.MinValue; if (Action == "guard") Input.Guard = false; if (Action == "stick") Input.SetStick(Vector2.zero); }
        private void OnDisable() { if (Input != null) Release(); }
    }
}
