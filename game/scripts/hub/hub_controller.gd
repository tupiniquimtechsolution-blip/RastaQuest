extends Node2D

@onready var start_button: Button = $Hud/Panel/VBox/StartRun
@onready var shards_label: Label = $Hud/Panel/VBox/Shards
@onready var progress_label: Label = $Hud/Panel/VBox/Progress

func _ready() -> void:
	SaveManager.load_save()
	_refresh()
	start_button.pressed.connect(_on_start_run)

func _refresh() -> void:
	shards_label.text = "Meta shards: %d" % SaveManager.meta_shards()
	var flags: Dictionary = SaveManager.data.get("completion_flags", {})
	progress_label.text = "Campaign: %s" % ("completed" if bool(flags.get("campaign_complete", false)) else "in progress")

func _on_start_run() -> void:
	RunManager.start_run(int(Time.get_unix_time_from_system()))
	get_tree().change_scene_to_file("res://scenes/world/RunPrototypeRoom.tscn")
