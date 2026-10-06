extends SceneTree

const SaveManagerScript = preload("res://scripts/save/save_manager.gd")
const BalanceValidator = preload("res://scripts/validation/balance_validator.gd")

func _init() -> void:
	if not _test_v1_to_v2_migration():
		return
	if not _test_clean_install_and_corruption_recovery():
		return
	var errors := BalanceValidator.validate_content()
	if not errors.is_empty():
		_fail("balance/content validation failed: %s" % errors)
		return
	print("RQ009_BETA_TECH_OK schema=2 rooms=18 upgrades=18")
	quit(0)

func _test_v1_to_v2_migration() -> bool:
	var legacy := {
		"schema_version": 1,
		"meta_shards": 17,
		"unlocks": ["axe_path"],
		"settings": {
			"screen_shake": false,
			"reduced_flashes": true,
			"vibration": false,
			"music_volume": 0.4,
			"sfx_volume": 0.7,
		},
		"completion_flags": {"forest_vertical_slice_complete": true},
	}
	var migrated := SaveManagerScript.migrate_data(legacy)
	if int(migrated.get("schema_version", 0)) != 2:
		return _fail("schema migration did not reach v2")
	if int(migrated.get("meta_shards", -1)) != 17:
		return _fail("meta shards lost during migration")
	if not bool(migrated["completion_flags"].get("forest_vertical_slice_complete", false)):
		return _fail("completion flag lost during migration")
	var settings: Dictionary = migrated["settings"]
	if float(settings.get("music_volume", -1.0)) != 0.4:
		return _fail("settings lost during migration")
	if not settings.has("touch_scale") or not settings.has("locale"):
		return _fail("v2 settings defaults missing after migration")
	return true

func _test_clean_install_and_corruption_recovery() -> bool:
	var primary := "user://rq009_beta.json"
	var backup := "user://rq009_beta.bak.json"
	_cleanup(primary)
	_cleanup(backup)

	var manager := SaveManagerScript.new()
	manager.configure_paths(primary, backup)
	manager.data = manager.default_data()
	if not manager.save_current(true):
		return _fail("clean-install default save failed")
	manager.add_meta_shards(4)
	manager.add_meta_shards(5)

	var corrupt := FileAccess.open(primary, FileAccess.WRITE)
	if corrupt == null:
		return _fail("unable to create corrupted primary fixture")
	corrupt.store_string("{broken")

	var recovered := manager.load_save()
	if int(recovered.get("meta_shards", -1)) != 4:
		return _fail("previous-good backup recovery failed")
	if int(recovered.get("schema_version", 0)) != 2:
		return _fail("recovered save is not current schema")

	_cleanup(primary)
	_cleanup(backup)
	manager.free()
	return true

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
