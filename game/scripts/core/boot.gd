extends Node2D

const InputDefaults = preload("res://scripts/core/input_defaults.gd")
const WAVE: String = "RQ-007"

func _ready() -> void:
	InputDefaults.ensure_defaults()
	var version: String = str(ProjectSettings.get_setting("application/config/version"))
	print("RASTA_QUEST_BOOT_OK wave=%s version=%s" % [WAVE, version])
	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(0)
