extends SceneTree

const SaveScript = preload("res://scripts/save/save_manager.gd")

class InterruptedSave extends "res://scripts/save/save_manager.gd":
	var truncate_stage := false
	var fail_backup := false
	var fail_primary := false
	var remove_primary := false
	func _stage_save(path: String, candidate: Dictionary) -> bool:
		if truncate_stage:
			var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
			file.store_string('{"schema_version":')
			file.close()
			return false
		return super._stage_save(path, candidate)
	func _commit_staged(source: String, destination: String) -> Error:
		if fail_backup and destination == backup_path:
			return ERR_CANT_CREATE
		if fail_primary and destination == save_path:
			if remove_primary:
				DirAccess.remove_absolute(ProjectSettings.globalize_path(save_path))
			return ERR_CANT_CREATE
		return super._commit_staged(source, destination)

func _init() -> void:
	var manager := InterruptedSave.new()
	manager.configure_paths("user://rq_atomic_smoke.json", "user://rq_atomic_smoke.bak.json")
	for path in [manager.save_path, manager.backup_path, manager.save_path + ".tmp", manager.backup_path + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	manager.data = manager.default_data()
	manager.data["meta_shards"] = 10
	assert(manager.save_current(true))
	manager.data["meta_shards"] = 20
	# skip_backup cannot leave an existing good primary without a recovery copy.
	assert(manager.save_current(true))
	assert(manager._read_raw(manager.save_path)["meta_shards"] == 20)
	assert(manager._read_raw(manager.backup_path)["meta_shards"] == 10)
	var primary := FileAccess.get_file_as_string(manager.save_path)
	var backup := FileAccess.get_file_as_string(manager.backup_path)
	manager.data["meta_shards"] = 30
	manager.truncate_stage = true
	assert(not manager.save_current())
	assert(FileAccess.get_file_as_string(manager.save_path) == primary)
	assert(FileAccess.get_file_as_string(manager.backup_path) == backup)
	manager.truncate_stage = false
	manager.data["unlocks"] = ["x".repeat(SaveScript.MAX_SAVE_BYTES + 1)]
	assert(not manager.save_current())
	assert(FileAccess.get_file_as_string(manager.save_path) == primary)
	assert(FileAccess.get_file_as_string(manager.backup_path) == backup)
	manager.data["unlocks"] = []
	manager.truncate_stage = false
	manager.fail_backup = true
	assert(not manager.save_current())
	assert(FileAccess.get_file_as_string(manager.save_path) == primary)
	assert(FileAccess.get_file_as_string(manager.backup_path) == backup)
	manager.fail_backup = false
	manager.fail_primary = true
	assert(not manager.save_current())
	assert(FileAccess.get_file_as_string(manager.save_path) == primary)
	assert(manager._read_raw(manager.backup_path)["meta_shards"] == 20)
	# Simulate Windows' delete/move gap: recovery still has previous-good progress.
	manager.remove_primary = true
	assert(not manager.save_current(true))
	manager.fail_primary = false
	manager.remove_primary = false
	assert(manager.load_save()["meta_shards"] == 20)
	assert(manager._read_raw(manager.save_path)["meta_shards"] == 20)
	# Corrupt primary must never overwrite the known-good backup on save.
	var file := FileAccess.open(manager.save_path, FileAccess.WRITE)
	file.store_string('{"schema_version":2,"settings":[]}')
	file.close()
	backup = FileAccess.get_file_as_string(manager.backup_path)
	manager.data["meta_shards"] = 40
	assert(manager.save_current())
	assert(FileAccess.get_file_as_string(manager.backup_path) == backup)
	manager.data["settings"] = []
	primary = FileAccess.get_file_as_string(manager.save_path)
	assert(not manager.save_current())
	assert(FileAccess.get_file_as_string(manager.save_path) == primary)
	for path in [manager.save_path, manager.backup_path, manager.save_path + ".tmp", manager.backup_path + ".tmp"]:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	manager.free()
	print("RQ_SAVE_ATOMIC_OK staged=pass failures=pass previous_good=pass")
	quit(0)
