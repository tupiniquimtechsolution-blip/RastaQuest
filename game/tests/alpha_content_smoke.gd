extends SceneTree

const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")
const UpgradeCatalog = preload("res://scripts/roguelike/upgrade_catalog.gd")
const RunState = preload("res://scripts/roguelike/run_state.gd")
const SaveManagerScript = preload("res://scripts/save/save_manager.gd")

func _init() -> void:
	if not _test_content_counts():
		return
	if not _test_campaign_progression():
		return
	if not _test_fresh_and_progressed_save():
		return
	if load("res://scenes/boss/FractureKing.tscn") == null:
		_fail("final boss scene missing")
		return
	print("RQ007_ALPHA_TECH_OK rooms=18 upgrades=18 synergies=5")
	quit(0)

func _test_content_counts() -> bool:
	var forest := RoomCatalog.load_biome(&"forest")
	var castle := RoomCatalog.load_biome(&"castle")
	var cave := RoomCatalog.load_biome(&"cave")
	if forest.size() != 6 or castle.size() != 6 or cave.size() != 6:
		return _fail("expected six curated rooms per biome")

	var ids: Dictionary = {}
	for room in forest + castle + cave:
		if room == null or ids.has(room.id):
			return _fail("invalid or duplicate room template")
		ids[room.id] = true

	var upgrades := UpgradeCatalog.load_all()
	if upgrades.size() != 18:
		return _fail("expected 18 upgrades")
	var upgrade_ids: Dictionary = {}
	var state := RunState.new()
	state.start(101)
	for upgrade in upgrades:
		if upgrade == null or upgrade.id == &"" or upgrade.effect_key == &"" or upgrade_ids.has(upgrade.id):
			return _fail("invalid upgrade data")
		upgrade_ids[upgrade.id] = true
		state.apply_upgrade(upgrade)
	if state.active_synergies().size() < 5:
		return _fail("expected at least five synergies")
	return true

func _test_campaign_progression() -> bool:
	var state := RunState.new()
	state.start(2026)
	var expected: Array[StringName] = [&"forest", &"castle", &"cave"]
	for biome_index in range(expected.size()):
		if state.biome != expected[biome_index]:
			return _fail("biome progression mismatch")
		for _encounter in range(4):
			state.advance_encounter()
		if biome_index < expected.size() - 1:
			if not state.advance_biome():
				return _fail("failed to advance biome")
	if state.biome != &"cave" or state.biome_depth != 4 or state.depth != 12:
		return _fail("campaign did not reach final-boss gate")
	return true

func _test_fresh_and_progressed_save() -> bool:
	var primary := "user://rq007_alpha.json"
	var backup := "user://rq007_alpha.bak.json"
	_cleanup(primary)
	_cleanup(backup)
	var manager := SaveManagerScript.new()
	manager.configure_paths(primary, backup)
	manager.data = manager.default_data()
	manager.save_current(true)
	manager.load_save()
	if manager.meta_shards() != 0:
		return _fail("fresh save was not fresh")
	manager.add_meta_shards(20)
	manager.set_completion_flag(&"campaign_complete", true)
	var reloaded := manager.load_save()
	var flags: Dictionary = reloaded.get("completion_flags", {})
	if int(reloaded.get("meta_shards", 0)) != 20 or not bool(flags.get("campaign_complete", false)):
		return _fail("progressed save did not persist")
	_cleanup(primary)
	_cleanup(backup)
	return true

func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
