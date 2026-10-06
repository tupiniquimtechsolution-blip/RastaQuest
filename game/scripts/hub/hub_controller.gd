extends Node2D

@onready var start_button: Button = $Hud/Panel/VBox/StartRun
@onready var shards_label: Label = $Hud/Panel/VBox/Shards

func _ready() -> void:
	SaveManager.load_save()
	_refresh()
	start_button.pressed.connect(_on_start_run)

func _refresh() -> void:
	shards_label.text = "Meta shards: %d" % SaveManager.meta_shards()

func _on_start_run() -> void:
	RunManager.start_run(int(Time.get_unix_time_from_system()))
	get_tree().change_scene_to_file("res://scenes/world/RunPrototypeRoom.tscn")
