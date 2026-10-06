extends Node

var suspend_save_count: int = 0

func persist_for_suspend() -> bool:
	var saved := SaveManager.save_current()
	if saved:
		suspend_save_count += 1
	return saved

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		persist_for_suspend()
