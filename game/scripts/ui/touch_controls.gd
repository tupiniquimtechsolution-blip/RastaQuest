extends CanvasLayer

@onready var left_button: Button = $LeftButton
@onready var right_button: Button = $RightButton
@onready var jump_button: Button = $JumpButton

func _ready() -> void:
	_bind_hold(left_button, &"move_left")
	_bind_hold(right_button, &"move_right")
	_bind_hold(jump_button, &"jump")

func _exit_tree() -> void:
	Input.action_release("move_left")
	Input.action_release("move_right")
	Input.action_release("jump")

func _bind_hold(button: BaseButton, action: StringName) -> void:
	button.button_down.connect(_press_action.bind(action))
	button.button_up.connect(_release_action.bind(action))

func _press_action(action: StringName) -> void:
	Input.action_press(action)

func _release_action(action: StringName) -> void:
	Input.action_release(action)
