extends SceneTree

const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")
const UpgradeCatalog = preload("res://scripts/roguelike/upgrade_catalog.gd")
const RunState = preload("res://scripts/roguelike/run_state.gd")
const SaveManagerScript = preload("res://scripts/save/save_manager.gd")

func _init() -> void:
	if not _validate_content():
		return
	if not _validate_campaign_progression():
		return
	if not _validate_fresh_save_to_victory_flag():
		return
	if load("res://scenes/boss/RiftSovereign.tscn") == null:
		_fail("final boss scene failed to load")
		return
	print("RQ007_ALPHA_TECH_OK rooms=18 upgrades=18 biomes=3")
	quit(0)

func _validate_content() -> bool:
	var all_rooms := RoomCatalog.load_all()
	if all_rooms.size() != 18:
		return _fail("expected 18 room templates")
	var ids: Dictionary = {}
	for room in all_rooms:
		if room == null or room.enemy_archetypes.is_empty():
			return _fail("invalid room")
		if ids.has(room.id):
			return _fail("duplicate room id")
		ids[room.id] = true
	var upgrades := UpgradeCatalog.load_all()
	if upgrades.size() != 18:
		return _fail("expected 18 upgrades")
	var upgrade_ids: Dictionary = {}
	for upgrade in upgrades:
		if upgrade == null or upgrade.id == &"":
			return _fail("invalid upgrade")
		if upgrade_ids.has(upgrade.id):
			return _fail("duplicate upgrade id")
		upgrade_ids[upgrade.id] = true
	if RunState.SYNERGY_RULES.size() < 5:
		return _fail("expected at least five synergy rules")
	return true

func _validate_campaign_progression() -> bool:
	var state := RunState.new()
	state.start(20261006)
	if state.biome != &"forest":
		return _fail("fresh run must start in forest")
	for _i in range(6):
		state.advance_encounter()
	if state.biome != &"castle" or state.depth != 6:
		return _fail("depth 6 must enter castle")
	for _i in range(6):
		state.advance_encounter()
	if state.biome != &"caves" or state.depth != 12:
		return _fail("depth 12 must enter caves")
	for _i in range(6):
		state.advance_encounter()
	if state.depth != 18:
		return _fail("campaign should reach final boss at depth 18")
	return true

func _validate_fresh_save_to_victory_flag() -> bool:
	var primary := "user://rq007_alpha.json"
	var backup := "user://rq007_alpha.bak.json"
	_cleanup(primary)
	_cleanup(backup)
	var manager := SaveManagerScript.new()
	manager.configure_paths(primary, backup)
	manager.data = manager.default_data()
	if not manager.save_current(true):
		return _fail("fresh save failed")
	manager.set_completion_flag(&"campaign_complete", true)
	manager.add_meta_shards(25)
	var flags: Dictionary = manager.data.get("completion_flags", {})
	if not bool(flags.get("campaign_complete", false)):
		return _fail("campaign completion was not persisted")
	if manager.meta_shards() != 25:
		return _fail("victory meta reward failed")
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
