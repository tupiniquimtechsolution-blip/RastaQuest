extends CanvasLayer

const Dialogs = preload("res://scripts/ui/menu_dialogs.gd")
const Settings = preload("res://scenes/ui/SettingsPanel.tscn")
var _settings_layer: CanvasLayer

@onready var panel: Control = $Panel
@onready var resume_button: Button = $Panel/VBox/Resume

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	resume_button.pressed.connect(_set_paused.bind(false))
	$Panel/VBox/Settings.pressed.connect(_open_settings)

func _open_settings() -> void:
	if not is_instance_valid(_settings_layer) or _settings_layer.is_queued_for_deletion():
		_settings_layer = Dialogs.open_panel(self, Settings)

func _process(_delta: float) -> void:
	if get_tree().get_nodes_in_group("onboarding_active").size() > 0:
		return
	if Input.is_action_just_pressed("pause"):
		_set_paused(not get_tree().paused)

func _set_paused(value: bool) -> void:
	if not value and is_instance_valid(_settings_layer):
		_settings_layer.queue_free()
	get_tree().paused = value
	panel.visible = value
