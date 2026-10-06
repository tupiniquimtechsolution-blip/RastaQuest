extends Control

const WAVE: String = "RQ-001"

@onready var status_label: Label = $CenterContainer/VBoxContainer/StatusLabel

func _ready() -> void:
	var version: String = str(ProjectSettings.get_setting("application/config/version"))
	status_label.text = "%s Bootstrap\n%s" % [WAVE, version]
	print("RASTA_QUEST_BOOT_OK wave=%s version=%s" % [WAVE, version])

	if "--smoke-test" in OS.get_cmdline_user_args():
		get_tree().quit(0)
