extends CanvasLayer

@onready var panel: Control = $Panel
@onready var text: Label = $Panel/VBox/Text
@onready var continue_button: Button = $Panel/VBox/Continue

var step: int = 0
const STEPS: Array[String] = [
	"Move with the left controls. Jump to cross broken ground.",
	"Use the axe to defeat enemies. Air attacks remain available while jumping.",
	"Clear encounters, enter portals and choose one of three upgrades.",
]

func _ready() -> void:
	if SaveManager.completion_flag(&"tutorial_complete"):
		queue_free()
		return
	continue_button.pressed.connect(_advance)
	_render()

func _advance() -> void:
	step += 1
	if step >= STEPS.size():
		SaveManager.set_completion_flag(&"tutorial_complete", true)
		queue_free()
		return
	_render()

func _render() -> void:
	text.text = STEPS[step]
