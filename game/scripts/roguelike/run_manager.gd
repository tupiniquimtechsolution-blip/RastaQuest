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

func sample_upgrade_choices(count: int = 3, needs_healing: bool = false) -> Array:
	var pool: Array = []
	var restoration: UpgradeData
	for upgrade in catalog:
		if upgrade.effect_key==&"heal":
			restoration = upgrade
		else:
			pool.append(upgrade)
	var result := state.sample_upgrades(pool,count)
	if needs_healing and count>0 and restoration!=null:
		if result.size()>=count:
			result.pop_back()
		result.append(restoration)
	return result

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
