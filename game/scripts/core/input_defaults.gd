extends RefCounted

const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"jump",
	&"attack",
	&"pause",
	&"interact",
]

static func ensure_defaults() -> void:
	for action: StringName in REQUIRED_ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)

	_add_key(&"move_left", KEY_A)
	_add_key(&"move_left", KEY_LEFT)
	_add_key(&"move_right", KEY_D)
	_add_key(&"move_right", KEY_RIGHT)
	_add_key(&"jump", KEY_SPACE)
	_add_key(&"attack", KEY_J)
	_add_key(&"pause", KEY_ESCAPE)
	_add_key(&"interact", KEY_E)

	_add_joy_axis(&"move_left", JOY_AXIS_LEFT_X, -1.0)
	_add_joy_axis(&"move_right", JOY_AXIS_LEFT_X, 1.0)
	_add_joy_button(&"jump", JOY_BUTTON_A)
	_add_joy_button(&"attack", JOY_BUTTON_X)
	_add_joy_button(&"pause", JOY_BUTTON_START)
	_add_joy_button(&"interact", JOY_BUTTON_Y)

static func _add_key(action: StringName, physical_keycode: int) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = physical_keycode
	_add_event_if_missing(action, event)

static func _add_joy_axis(action: StringName, axis: int, axis_value: float) -> void:
	var event := InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	_add_event_if_missing(action, event)

static func _add_joy_button(action: StringName, button_index: int) -> void:
	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	_add_event_if_missing(action, event)

static func _add_event_if_missing(action: StringName, event: InputEvent) -> void:
	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
