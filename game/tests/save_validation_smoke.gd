extends SceneTree

const SaveScript = preload("res://scripts/save/save_manager.gd")

func _init() -> void:
	var defaults := SaveScript.new()
	var valid: Dictionary = defaults.default_data()
	defaults.free()
	for key in ["settings", "meta_shards", "schema_version"]:
		for bad in [null, [], "invalid", {}]:
			if key == "settings" and typeof(bad) == TYPE_DICTIONARY:
				continue
			var candidate: Dictionary = valid.duplicate(true)
			candidate[key] = bad
			if not SaveScript.migrate_data(candidate).is_empty():
				push_error("Malformed save field accepted: %s" % key)
				quit(1)
				return
	for bad_shards in [-1, 1.5]:
		var candidate: Dictionary = valid.duplicate(true)
		candidate["meta_shards"] = bad_shards
		if not SaveScript.migrate_data(candidate).is_empty():
			push_error("Invalid shard count accepted")
			quit(1)
			return
	for key in ["music_volume", "sfx_volume", "touch_scale"]:
		var candidate: Dictionary = valid.duplicate(true)
		candidate["settings"][key] = []
		if not SaveScript.migrate_data(candidate).is_empty():
			push_error("Malformed setting accepted")
			quit(1)
			return
	for field in ["unlocks", "completion_flags"]:
		var candidate: Dictionary = valid.duplicate(true)
		candidate[field] = [42] if field == "unlocks" else {"done": "yes"}
		if not SaveScript.migrate_data(candidate).is_empty():
			push_error("Malformed nested save value accepted")
			quit(1)
			return
	# Valid JSON with invalid schema must recover from a known-good backup.
	var manager := SaveScript.new()
	manager.configure_paths("user://rq_security_test.json", "user://rq_security_test.bak.json")
	var file := FileAccess.open(manager.backup_path, FileAccess.WRITE)
	valid["meta_shards"] = 7
	file.store_string(JSON.stringify(valid))
	file.close()
	file = FileAccess.open(manager.save_path, FileAccess.WRITE)
	file.store_string('{"schema_version":2,"settings":[]}')
	file.close()
	if manager.load_save().get("meta_shards") != 7:
		push_error("Malformed primary did not recover from backup")
		quit(1)
		return
	file = FileAccess.open(manager.save_path, FileAccess.WRITE)
	file.store_string(" ".repeat(SaveScript.MAX_SAVE_BYTES + 1))
	file.close()
	if manager.load_save().get("meta_shards") != 7:
		push_error("Oversized primary did not recover from backup")
		quit(1)
		return
	var candidate: Dictionary = valid.duplicate(true)
	candidate["settings"]["music_volume"] = 9.0
	if SaveScript.migrate_data(candidate)["settings"]["music_volume"] != 1.0:
		push_error("Settings bounds not normalized")
		quit(1)
		return
	DirAccess.remove_absolute(ProjectSettings.globalize_path(manager.save_path))
	DirAccess.remove_absolute(ProjectSettings.globalize_path(manager.backup_path))
	manager.free()
	print("RQ_SAVE_VALIDATION_OK malformed_fields=checked backup=pass")
	quit(0)
