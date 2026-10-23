extends CanvasLayer

const Pad = preload("res://scripts/ui/touch_pad.gd")
var joystick: Control
var jump_button: Control
var attack_button: Control
var guard_button: Control
var pause_button: Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("touch_controls")
	joystick = _pad("Joystick",&"",null,true)
	jump_button = _pad("JumpButton",&"jump",preload("res://assets/ui/jump.svg"))
	attack_button = _pad("AttackButton",&"attack",preload("res://assets/ui/axe.svg"))
	guard_button = _pad("GuardButton",&"guard",preload("res://assets/ui/shield.svg"))
	pause_button = _pad("PauseButton",&"pause")
	SettingsManager.settings_changed.connect(_apply_scale)
	get_viewport().size_changed.connect(_on_resize)
	_apply_scale()

func _pad(label: String, action: StringName, texture: Texture2D = null, analog := false) -> Control:
	var pad := Pad.new()
	pad.name = label
	pad.action = action
	pad.analog = analog
	pad.icon = texture
	add_child(pad)
	return pad

func _apply_scale() -> void:
	var factor := float(SettingsManager.get_value(&"touch_scale",1.0))
	var extent := get_viewport().get_visible_rect().size
	_place(joystick,Vector2(32,extent.y-32-180*factor),180*factor)
	_place(jump_button,Vector2(extent.x-28-128*factor,extent.y-28-128*factor),128*factor)
	_place(attack_button,Vector2(extent.x-44-256*factor,extent.y-28-128*factor),128*factor)
	_place(guard_button,Vector2(extent.x-36-192*factor,extent.y-44-256*factor),108*factor)
	_place(pause_button,Vector2(extent.x-76,20),52)

func _place(pad: Control, at: Vector2, diameter: float) -> void:
	pad.position = at
	pad.size = Vector2.ONE*diameter
	pad.queue_redraw()

func release_held_actions() -> void:
	for pad in [joystick,jump_button,attack_button,guard_button,pause_button]:
		if is_instance_valid(pad):
			pad.release()
	for action in ["move_left","move_right","jump","jump_stick","attack","guard"]:
		Input.action_release(action)
	var scene := get_tree().current_scene
	if scene != null:
		var player := scene.get_node_or_null("Player")
		if player != null and not player.is_queued_for_deletion() and player.has_method("cancel_action_inputs"):
			player.cancel_action_inputs()

func _on_resize() -> void:
	release_held_actions()
	_apply_scale()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_PAUSED:
		release_held_actions()

func _exit_tree() -> void:
	release_held_actions()
	Input.action_release("pause")
