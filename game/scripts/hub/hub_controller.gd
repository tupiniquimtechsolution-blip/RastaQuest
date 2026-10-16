extends Node2D

const Dialogs = preload("res://scripts/ui/menu_dialogs.gd")
const Settings = preload("res://scenes/ui/SettingsPanel.tscn")
const Credits = preload("res://scenes/ui/CreditsPanel.tscn")

@onready var start_button: Button = $Hud/Panel/VBox/StartRun
@onready var shards_label: Label = $Hud/Panel/VBox/Shards
var _menu_layer: CanvasLayer

func _ready() -> void:
	SaveManager.load_save()
	_refresh()
	start_button.pressed.connect(_on_start_run)
	$Hud/Panel/VBox/Settings.pressed.connect(_open_menu.bind(Settings))
	$Hud/Panel/VBox/Credits.pressed.connect(_open_menu.bind(Credits))

func _open_menu(scene: PackedScene) -> void:
	if not is_instance_valid(_menu_layer) or _menu_layer.is_queued_for_deletion():
		_menu_layer = Dialogs.open_panel(self, scene)

func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		_refresh()

func _refresh() -> void:
	shards_label.text = tr("meta_shards") % SaveManager.meta_shards()

func _on_start_run() -> void:
	RunManager.start_run(int(Time.get_unix_time_from_system()))
	get_tree().change_scene_to_file("res://scenes/world/RunPrototypeRoom.tscn")
