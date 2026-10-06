extends SceneTree

const SaveManagerScript = preload("res://scripts/save/save_manager.gd")
const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")
const AudioManagerScript = preload("res://scripts/core/audio_manager.gd")

func _init() -> void:
	if not _test_forest_content():
		return
	if not _test_save_roundtrip_and_recovery():
		return
	if not _test_required_scenes():
		return
	if not _test_audio_buses():
		return
	print("RQ006_VERTICAL_SLICE_TECH_OK rooms=6 save_recovery=pass")
	quit(0)

func _test_forest_content() -> bool:
	var rooms := RoomCatalog.load_forest()
	if rooms.size() != 6:
		return _fail("vertical slice requires six curated forest room templates")

	var ids: Dictionary = {}
	var has_elite := false
	for room in rooms:
		if room == null or room.enemy_archetypes.is_empty() or room.spawn_positions.is_empty():
			return _fail("invalid forest room template")
		if ids.has(room.id):
			return _fail("duplicate forest room id")
		ids[room.id] = true
		has_elite = has_elite or room.elite_room

	if not has_elite:
		return _fail("forest slice requires an elite room")
	return true

func _test_save_roundtrip_and_recovery() -> bool:
	var primary := "user://rq006_ci_save.json"
	var backup := "user://rq006_ci_save.bak.json"
	_cleanup(primary)
	_cleanup(backup)

	var manager := SaveManagerScript.new()
	manager.configure_paths(primary, backup)
	manager.data = manager.default_data()
	if not manager.save_current(true):
		return _fail("initial save failed")

	manager.add_meta_shards(3)
	manager.add_meta_shards(2)
	if manager.meta_shards() != 5:
		return _fail("meta progression save failed")

	var corrupt := FileAccess.open(primary, FileAccess.WRITE)
	if corrupt == null:
		return _fail("could not create corruption fixture")
	corrupt.store_string("{broken-json")

	var recovered := manager.load_save()
	if int(recovered.get("meta_shards", -1)) != 3:
		return _fail("corrupted-save recovery did not restore previous-good backup")

	_cleanup(primary)
	_cleanup(backup)
	return true

func _test_required_scenes() -> bool:
	var required := [
		"res://scenes/hub/Hub.tscn",
		"res://scenes/world/RunPrototypeRoom.tscn",
		"res://scenes/boss/StormWarden.tscn",
		"res://scenes/ui/PauseOverlay.tscn",
	]
	for path in required:
		if not ResourceLoader.exists(path):
			return _fail("required vertical-slice scene resource missing: %s" % path)
	return true

func _test_audio_buses() -> bool:
	var audio := AudioManagerScript.new()
	audio._ready()
	if AudioServer.get_bus_index(&"Music") < 0 or AudioServer.get_bus_index(&"SFX") < 0:
		return _fail("Music/SFX audio buses were not created")
	return true

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
