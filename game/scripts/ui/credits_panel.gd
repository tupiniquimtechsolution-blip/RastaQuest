extends Control

signal closed

func _ready() -> void:
	$Panel/VBox/Close.pressed.connect(closed.emit)
	# Read actual embedded engine notices, without claiming approval of game assets.
	$Panel/VBox/Notices.text = "Rasta Quest\nGodot Engine\n\n" + Engine.get_license_text() + "\n\n" + JSON.stringify(Engine.get_copyright_info(), "\t") + "\n\n" + JSON.stringify(Engine.get_license_info(), "\t")
