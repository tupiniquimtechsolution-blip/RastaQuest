extends SceneTree

const RunState = preload("res://scripts/roguelike/run_state.gd")
const UpgradeCatalog = preload("res://scripts/roguelike/upgrade_catalog.gd")

const ROOMS: Array[StringName] = [
	&"forest_gate",
	&"forest_bridge",
	&"forest_shrine",
	&"forest_roots",
	&"forest_ruin",
	&"forest_portal",
]

func _init() -> void:
	var catalog := UpgradeCatalog.load_all()
	if catalog.size() < 12:
		_fail("expected at least 12 functional upgrades")
		return
	if not _test_seed_reproduction(catalog):
		return
	if not _test_upgrades_and_synergies(catalog):
		return
	if not _test_sequential_encounters():
		return
	if not _test_reset(catalog):
		return
	print("RQ005_ROGUELIKE_CORE_OK encounters=100 upgrades=12")
	quit(0)

func _test_seed_reproduction(catalog: Array) -> bool:
	var left := RunState.new()
	var right := RunState.new()
	left.start(777)
	right.start(777)

	for _index in range(20):
		if left.choose_room(ROOMS) != right.choose_room(ROOMS):
			return _fail("same seed produced different room sequence")

	var left_choices := left.sample_upgrades(catalog, 3)
	var right_choices := right.sample_upgrades(catalog, 3)
	if left_choices.size() != 3 or right_choices.size() != 3:
		return _fail("one-of-three reward did not produce three choices")

	for index in range(3):
		if left_choices[index].id != right_choices[index].id:
			return _fail("same seed produced different upgrade choices")
	return true

func _test_upgrades_and_synergies(catalog: Array) -> bool:
	var state := RunState.new()
	state.start(123)

	for upgrade in catalog:
		if upgrade == null or not state.apply_upgrade(upgrade):
			return _fail("invalid/null/duplicate upgrade application")

	if state.applied_upgrade_ids.size() != catalog.size():
		return _fail("not all catalog upgrades applied")
	if state.active_synergies().size() < 3:
		return _fail("expected at least three observable synergies")
	if float(state.modifiers[&"chain_lightning"]) <= 0.0:
		return _fail("chain lightning upgrade did not activate")
	if float(state.modifiers[&"on_kill_aoe"]) <= 0.0:
		return _fail("on-kill AOE upgrade did not activate")
	return true

func _test_sequential_encounters() -> bool:
	var state := RunState.new()
	state.start(555)

	for cycle in range(100):
		var room := state.choose_room(ROOMS)
		if room == &"":
			return _fail("portal cycle selected invalid room")
		var depth := state.advance_encounter()
		if depth != cycle + 1:
			return _fail("portal cycle depth mismatch")

	if state.depth < 10:
		return _fail("run did not support 10+ sequential encounters")
	return true

func _test_reset(catalog: Array) -> bool:
	var state := RunState.new()
	state.start(999)
	state.apply_upgrade(catalog[0])
	state.advance_encounter()
	state.reset_after_death()

	if state.run_active:
		return _fail("death reset left run active")
	if state.depth != 0 or not state.applied_upgrade_ids.is_empty():
		return _fail("death reset retained temporary run state")
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
