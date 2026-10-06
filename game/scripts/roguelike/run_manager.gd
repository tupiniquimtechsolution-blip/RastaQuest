extends Node

const RunState = preload("res://scripts/roguelike/run_state.gd")
const UpgradeCatalog = preload("res://scripts/roguelike/upgrade_catalog.gd")

signal run_started(seed_value: int)
signal encounter_advanced(depth: int)
signal upgrade_applied(upgrade_id: StringName)
signal run_ended

var state := RunState.new()
var catalog: Array = []

func _ready() -> void:
	catalog = UpgradeCatalog.load_all()

func start_run(seed_override: int = 424242) -> void:
	state.start(seed_override)
	run_started.emit(state.seed_value)

func sample_upgrade_choices(count: int = 3) -> Array:
	return state.sample_upgrades(catalog, count)

func apply_upgrade(upgrade: UpgradeData) -> bool:
	var applied := state.apply_upgrade(upgrade)
	if applied:
		upgrade_applied.emit(upgrade.id)
	return applied

func advance_encounter() -> int:
	var depth := state.advance_encounter()
	encounter_advanced.emit(depth)
	return depth

func end_run() -> void:
	state.reset_after_death()
	run_ended.emit()
