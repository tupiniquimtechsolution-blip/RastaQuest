extends RefCounted

const BIOMES: Array[StringName] = [&"forest", &"castle", &"cave"]
const SYNERGY_RULES := {
	&"thunder_web": [&"electric", &"chain"],
	&"execution_storm": [&"electric", &"execution"],
	&"stormrunner": [&"electric", &"mobility"],
	&"guardian_flow": [&"survival", &"mobility"],
	&"sky_execution": [&"air", &"execution"],
}

var seed_value: int = 1
var depth: int = 0
var biome_index: int = 0
var biome: StringName = &"forest"
var biome_depth: int = 0
var run_active: bool = false
var applied_upgrade_ids: Array[StringName] = []
var _tags: Dictionary = {}
var modifiers: Dictionary = {}
var debug_log: Array[String] = []
var _rng := RandomNumberGenerator.new()

func start(seed_override: int = 1) -> void:
	seed_value = seed_override if seed_override != 0 else 1
	_rng.seed = seed_value
	depth = 0
	biome_index = 0
	biome = BIOMES[0]
	biome_depth = 0
	run_active = true
	applied_upgrade_ids.clear()
	_tags.clear()
	debug_log.clear()
	modifiers = {
		&"damage": 0.0, &"air_damage": 0.0, &"move_speed": 0.0, &"jump_power": 0.0,
		&"max_health": 0.0, &"invulnerability": 0.0, &"proc_chance": 0.0,
		&"cooldown_reduction": 0.0, &"chain_lightning": 0.0, &"on_kill_aoe": 0.0,
	}
	debug_log.append("run_start seed=%d" % seed_value)

func choose_room(room_ids: Array[StringName]) -> StringName:
	if room_ids.is_empty():
		return &""
	var index := _rng.randi_range(0, room_ids.size() - 1)
	var room_id: StringName = room_ids[index]
	debug_log.append("room depth=%d biome=%s biome_depth=%d id=%s" % [depth, biome, biome_depth, room_id])
	return room_id

func sample_upgrades(catalog: Array, count: int = 3) -> Array:
	if catalog.is_empty() or count <= 0:
		return []
	var available: Array = []
	for upgrade in catalog:
		if upgrade != null and not applied_upgrade_ids.has(upgrade.id):
			available.append(upgrade)
	var result: Array = []
	while not available.is_empty() and result.size() < count:
		var index := _rng.randi_range(0, available.size() - 1)
		result.append(available.pop_at(index))
	return result

func apply_upgrade(upgrade: UpgradeData) -> bool:
	if upgrade == null or applied_upgrade_ids.has(upgrade.id):
		return false
	applied_upgrade_ids.append(upgrade.id)
	modifiers[upgrade.effect_key] = float(modifiers.get(upgrade.effect_key, 0.0)) + upgrade.effect_value
	for tag in upgrade.tags:
		_tags[tag] = int(_tags.get(tag, 0)) + 1
	debug_log.append("upgrade depth=%d id=%s" % [depth, upgrade.id])
	return true

func active_synergies() -> Array[StringName]:
	var result: Array[StringName] = []
	for synergy_id: StringName in SYNERGY_RULES:
		var required_tags: Array = SYNERGY_RULES[synergy_id]
		var active := true
		for tag in required_tags:
			if int(_tags.get(tag, 0)) <= 0:
				active = false
				break
		if active:
			result.append(synergy_id)
	return result

func advance_encounter() -> int:
	depth += 1
	biome_depth += 1
	debug_log.append("advance depth=%d biome=%s biome_depth=%d" % [depth, biome, biome_depth])
	return depth

func advance_biome() -> bool:
	if biome_index >= BIOMES.size() - 1:
		return false
	biome_index += 1
	biome = BIOMES[biome_index]
	biome_depth = 0
	debug_log.append("biome_advance biome=%s" % biome)
	return true

func reset_after_death() -> void:
	debug_log.append("run_end depth=%d" % depth)
	run_active = false
	depth = 0
	biome_index = 0
	biome = BIOMES[0]
	biome_depth = 0
	applied_upgrade_ids.clear()
	_tags.clear()
	for key in modifiers.keys():
		modifiers[key] = 0.0
