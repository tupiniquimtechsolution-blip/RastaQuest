extends Node

const CURRENT_SCHEMA_VERSION: int = 1

var save_path: String = "user://rasta_quest_save.json"
var backup_path: String = "user://rasta_quest_save.bak.json"
var data: Dictionary = {}

func _ready() -> void:
	load_save()

func configure_paths(primary: String, backup: String) -> void:
	save_path = primary
	backup_path = backup

func default_data() -> Dictionary:
	return {
		"schema_version": CURRENT_SCHEMA_VERSION,
		"meta_shards": 0,
		"unlocks": [],
		"settings": {
			"screen_shake": true,
			"reduced_flashes": false,
			"vibration": true,
			"music_volume": 1.0,
			"sfx_volume": 1.0,
		},
		"completion_flags": {},
	}

func load_save() -> Dictionary:
	var primary := _read_valid(save_path)
	if not primary.is_empty():
		data = primary
		return data

	var backup := _read_valid(backup_path)
	if not backup.is_empty():
		data = backup
		save_current(true)
		return data

	data = default_data()
	save_current(true)
	return data

func save_current(skip_backup: bool = false) -> bool:
	if data.is_empty():
		data = default_data()
	data["schema_version"] = CURRENT_SCHEMA_VERSION

	if not skip_backup and FileAccess.file_exists(save_path):
		var existing := FileAccess.get_file_as_string(save_path)
		if not existing.is_empty():
			var backup_file := FileAccess.open(backup_path, FileAccess.WRITE)
			if backup_file != null:
				backup_file.store_string(existing)

	var file := FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true

func add_meta_shards(amount: int) -> void:
	if data.is_empty():
		load_save()
	data["meta_shards"] = maxi(int(data.get("meta_shards", 0)) + amount, 0)
	save_current()

func meta_shards() -> int:
	return int(data.get("meta_shards", 0))

func set_completion_flag(flag: StringName, value: bool = true) -> void:
	var flags: Dictionary = data.get("completion_flags", {})
	flags[String(flag)] = value
	data["completion_flags"] = flags
	save_current()

func _read_valid(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	var candidate: Dictionary = parsed
	if int(candidate.get("schema_version", -1)) != CURRENT_SCHEMA_VERSION:
		return {}
	return candidate
