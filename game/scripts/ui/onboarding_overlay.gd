extends CanvasLayer

@onready var panel: Control = $Panel
@onready var text: Label = $Panel/VBox/Text
@onready var continue_button: Button = $Panel/VBox/Continue

var step: int = 0
var _owns_pause := false
var _previous_pause := false
const STEPS: Array[String] = [
	"tutorial_move",
	"tutorial_combat",
	"tutorial_run",
]

func _ready() -> void:
	if SaveManager.completion_flag(&"tutorial_complete"):
		queue_free()
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("onboarding_active")
	_previous_pause = get_tree().paused
	_owns_pause = true
	get_tree().paused = true
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
	text.text = tr(STEPS[step])

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready() and step < STEPS.size():
		_render()

func _exit_tree() -> void:
	if _owns_pause:
		get_tree().paused = _previous_pause
