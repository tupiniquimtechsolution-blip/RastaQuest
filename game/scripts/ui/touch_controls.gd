extends CanvasLayer

@onready var left_button: Button = $LeftButton
@onready var right_button: Button = $RightButton
@onready var jump_button: Button = $JumpButton
@onready var attack_button: Button = $AttackButton
@onready var pause_button: Button = $PauseButton

func _ready() -> void:
	add_to_group("touch_controls")
	_bind_hold(left_button, &"move_left")
	_bind_hold(right_button, &"move_right")
	_bind_hold(jump_button, &"jump")
	_bind_hold(attack_button, &"attack")
	pause_button.pressed.connect(_pulse_action.bind(&"pause"))
	SettingsManager.settings_changed.connect(_apply_scale)
	_apply_scale()

func _apply_scale() -> void:
	var factor := float(SettingsManager.get_value(&"touch_scale", 1.0))
	var widths := [88.0, 100.0, 156.0, 156.0, 76.0]
	var heights := [100.0, 100.0, 120.0, 100.0, 52.0]
	var buttons := [left_button, right_button, jump_button, attack_button, pause_button]
	for i in range(buttons.size()):
		var button: Button = buttons[i]
		button.add_theme_font_size_override("font_size", maxi(12, int(16.0 * factor)))
		button.anchor_left = 0.0 if i < 2 else 1.0
		button.anchor_right = button.anchor_left
		button.anchor_top = 0.0 if i == 4 else 1.0
		button.anchor_bottom = button.anchor_top
		var width: float = widths[i] * factor
		var height: float = heights[i] * factor
		if i < 2:
			button.offset_left = 24.0 if i == 0 else 36.0 + widths[0] * factor
			button.offset_right = button.offset_left + width
		else:
			button.offset_right = -24.0 if i != 3 else -38.0 - widths[2] * factor
			button.offset_left = button.offset_right - width
		button.offset_top = 20.0 if i == 4 else -30.0 - height
		button.offset_bottom = button.offset_top + height

func release_held_actions() -> void:
	for action in ["move_left", "move_right", "jump", "attack"]:
		Input.action_release(action)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		release_held_actions()

func _exit_tree() -> void:
	release_held_actions()
	Input.action_release("pause")

func _bind_hold(button: BaseButton, action: StringName) -> void:
	button.button_down.connect(_press_action.bind(action))
	button.button_up.connect(_release_action.bind(action))

func _press_action(action: StringName) -> void:
	Input.action_press(action)

func _release_action(action: StringName) -> void:
	Input.action_release(action)

func _pulse_action(action: StringName) -> void:
	Input.action_press(action)
	Input.action_release(action)
