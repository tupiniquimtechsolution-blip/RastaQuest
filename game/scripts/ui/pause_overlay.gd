extends CanvasLayer

@onready var panel: Control = $Panel
@onready var resume_button: Button = $Panel/VBox/Resume

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	resume_button.pressed.connect(_set_paused.bind(false))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_set_paused(not get_tree().paused)

func _set_paused(value: bool) -> void:
	get_tree().paused = value
	panel.visible = value
