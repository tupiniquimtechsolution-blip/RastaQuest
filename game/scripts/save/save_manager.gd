extends Node

const CURRENT_SCHEMA_VERSION: int = 2
const DEFAULT_SETTINGS := {
	"screen_shake": true,
	"reduced_flashes": false,
	"vibration": true,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"touch_scale": 1.0,
	"locale": "en",
}

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
		"settings": DEFAULT_SETTINGS.duplicate(true),
		"completion_flags": {},
	}

static func migrate_data(candidate: Dictionary) -> Dictionary:
	if candidate.is_empty():
		return {}

	var version := int(candidate.get("schema_version", -1))
	if version < 1 or version > CURRENT_SCHEMA_VERSION:
		return {}

	var migrated := candidate.duplicate(true)
	if version == 1:
		var settings: Dictionary = migrated.get("settings", {})
		for key in DEFAULT_SETTINGS:
			if not settings.has(key):
				settings[key] = DEFAULT_SETTINGS[key]
		migrated["settings"] = settings
		migrated["schema_version"] = 2
		version = 2

	if version == 2:
		if not migrated.has("meta_shards"):
			migrated["meta_shards"] = 0
		if not migrated.has("unlocks") or typeof(migrated["unlocks"]) != TYPE_ARRAY:
			migrated["unlocks"] = []
		if not migrated.has("completion_flags") or typeof(migrated["completion_flags"]) != TYPE_DICTIONARY:
			migrated["completion_flags"] = {}
		var settings: Dictionary = migrated.get("settings", {})
		for key in DEFAULT_SETTINGS:
			if not settings.has(key):
				settings[key] = DEFAULT_SETTINGS[key]
		migrated["settings"] = settings

	return migrated

func load_save() -> Dictionary:
	var raw_primary := _read_raw(save_path)
	var primary := migrate_data(raw_primary)
	if not primary.is_empty():
		var migrated := int(raw_primary.get("schema_version", -1)) != CURRENT_SCHEMA_VERSION
		data = primary
		if migrated:
			_write_backup_raw(raw_primary)
			save_current(true)
		return data

	var raw_backup := _read_raw(backup_path)
	var backup := migrate_data(raw_backup)
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
	data = migrate_data(data)
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

func completion_flag(flag: StringName) -> bool:
	var flags: Dictionary = data.get("completion_flags", {})
	return bool(flags.get(String(flag), false))

func set_setting(key: StringName, value: Variant) -> void:
	if data.is_empty():
		load_save()
	var settings: Dictionary = data.get("settings", {})
	settings[String(key)] = value
	data["settings"] = settings
	save_current()

func setting(key: StringName, fallback: Variant = null) -> Variant:
	var settings: Dictionary = data.get("settings", {})
	return settings.get(String(key), fallback)

func set_completion_flag(flag: StringName, value: bool = true) -> void:
	var flags: Dictionary = data.get("completion_flags", {})
	flags[String(flag)] = value
	data["completion_flags"] = flags
	save_current()

func _read_raw(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed

func _write_backup_raw(candidate: Dictionary) -> void:
	if candidate.is_empty():
		return
	var file := FileAccess.open(backup_path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(candidate))
