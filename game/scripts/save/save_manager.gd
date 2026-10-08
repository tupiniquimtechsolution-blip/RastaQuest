extends Node

const CURRENT_SCHEMA_VERSION: int = 2
const MAX_SAVE_BYTES: int = 1048576
const SettingsPolicy = preload("res://scripts/core/settings_policy.gd")
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
	if not _valid_shape(candidate):
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

	migrated["settings"] = SettingsPolicy.normalize(migrated["settings"])
	return migrated

static func _valid_shape(candidate: Dictionary) -> bool:
	var version: Variant = candidate.get("schema_version")
	if not _integer_number(version):
		return false
	var shards: Variant = candidate.get("meta_shards", 0)
	if not _integer_number(shards) or float(shards) < 0.0:
		return false
	var settings: Variant = candidate.get("settings", {})
	if typeof(settings) != TYPE_DICTIONARY:
		return false
	for key in ["screen_shake", "reduced_flashes", "vibration"]:
		if settings.has(key) and typeof(settings[key]) != TYPE_BOOL:
			return false
	for key in ["music_volume", "sfx_volume", "touch_scale"]:
		if settings.has(key) and not _finite_number(settings[key]):
			return false
	if settings.has("locale") and typeof(settings["locale"]) != TYPE_STRING:
		return false
	# Existing migration repairs invalid unlock/flag containers. Validate entries
	# only when the container has the expected type, preserving that behavior.
	var unlocks: Variant = candidate.get("unlocks", [])
	if typeof(unlocks) == TYPE_ARRAY:
		for item: Variant in unlocks:
			if typeof(item) != TYPE_STRING:
				return false
	var flags: Variant = candidate.get("completion_flags", {})
	if typeof(flags) == TYPE_DICTIONARY:
		for value: Variant in flags.values():
			if typeof(value) != TYPE_BOOL:
				return false
	return true

static func _finite_number(value: Variant) -> bool:
	return typeof(value) in [TYPE_INT, TYPE_FLOAT] and is_finite(float(value))

static func _integer_number(value: Variant) -> bool:
	return _finite_number(value) and float(value) == floorf(float(value)) and absf(float(value)) < 9223372036854775808.0

func load_save() -> Dictionary:
	var raw_primary := _read_raw(save_path)
	var primary := migrate_data(raw_primary)
	if not primary.is_empty():
		var migrated := int(raw_primary.get("schema_version", -1)) != CURRENT_SCHEMA_VERSION
		data = primary
		if migrated:
			if _write_backup_raw(raw_primary):
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
	var candidate := migrate_data(data)
	if candidate.is_empty() or save_path == backup_path:
		return false
	candidate["schema_version"] = CURRENT_SCHEMA_VERSION
	# Prepare and verify the complete replacement before touching either live file.
	if not _stage_save(save_path, candidate):
		return false
	var existing := _read_raw(save_path)
	if not migrate_data(existing).is_empty():
		# Even skip_backup must retain a recovery copy when one does not exist.
		# Godot's Windows rename removes an existing destination before moving.
		if not skip_backup or migrate_data(_read_raw(backup_path)).is_empty():
			if not _write_backup_raw(existing):
				return false
	if _commit_staged(save_path + ".tmp", save_path) != OK:
		return false
	data = candidate
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
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > MAX_SAVE_BYTES:
		return {}
	var text := file.get_as_text()
	var parser := JSON.new()
	if parser.parse(text) != OK or typeof(parser.data) != TYPE_DICTIONARY:
		return {}
	return parser.data

func _write_backup_raw(candidate: Dictionary) -> bool:
	if migrate_data(candidate).is_empty() or not _stage_save(backup_path, candidate):
		return false
	return _commit_staged(backup_path + ".tmp", backup_path) == OK

func _stage_save(path: String, candidate: Dictionary) -> bool:
	var text := JSON.stringify(candidate)
	if text.to_utf8_buffer().size() > MAX_SAVE_BYTES:
		return false
	var file := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(text)
	file.flush()
	var error := file.get_error()
	file.close()
	if error != OK:
		return false
	return FileAccess.get_file_as_string(path + ".tmp") == text and not migrate_data(_read_raw(path + ".tmp")).is_empty()

func _commit_staged(source: String, destination: String) -> Error:
	return DirAccess.rename_absolute(ProjectSettings.globalize_path(source), ProjectSettings.globalize_path(destination))
