extends SceneTree

const AttackRegistry = preload("res://scripts/combat/attack_registry.gd")
const HealthComponent = preload("res://scripts/combat/health_component.gd")
const Priority = preload("res://scripts/combat/combat_state_priority.gd")
const CombatEffects = preload("res://scripts/combat/combat_effects.gd")

func _init() -> void:
	if not _test_attack_registry():
		return
	if not _test_health():
		return
	if not _test_priority():
		return
	if not _test_electrical_determinism():
		return
	if not _test_chain_and_aoe_selection():
		return
	print("RQ003_COMBAT_OK")
	quit(0)

func _test_attack_registry() -> bool:
	var registry := AttackRegistry.new()
	registry.begin_attack(1)
	if not registry.can_hit(42):
		return _fail("fresh target must be hittable")
	registry.mark_hit(42)
	if registry.can_hit(42):
		return _fail("same attack cannot double-hit same target")
	registry.begin_attack(2)
	if not registry.can_hit(42):
		return _fail("new attack must allow target again")
	return true

func _test_health() -> bool:
	var health := HealthComponent.new()
	health.max_health = 3
	health.reset_health()
	if not health.take_damage(1, true) or health.health != 2:
		return _fail("health damage contract failed")
	if not health.take_damage(2, true) or not health.dead:
		return _fail("death contract failed")
	if health.take_damage(1, true):
		return _fail("dead target accepted damage")
	return true

func _test_priority() -> bool:
	if Priority.resolve(true, true, &"attack_axe", true, Vector2.ZERO) != &"death":
		return _fail("death priority failed")
	if Priority.resolve(false, true, &"attack_axe", true, Vector2.ZERO) != &"hurt":
		return _fail("hurt priority failed")
	if Priority.resolve(false, false, &"attack_axe", true, Vector2.ZERO) != &"attack_axe":
		return _fail("attack priority failed")
	if Priority.resolve(false, false, &"", false, Vector2(0, -10)) != &"jump":
		return _fail("air movement priority failed")
	return true

func _test_electrical_determinism() -> bool:
	var left := CombatEffects.new(9001)
	var right := CombatEffects.new(9001)
	for _index in range(32):
		if left.roll_electrical_proc(0.37) != right.roll_electrical_proc(0.37):
			return _fail("fixed-seed electrical proc diverged")
	if CombatEffects.new(1).roll_electrical_proc(0.0):
		return _fail("zero proc chance must be false")
	if not CombatEffects.new(1).roll_electrical_proc(1.0):
		return _fail("full proc chance must be true")
	return true

func _test_chain_and_aoe_selection() -> bool:
	var candidates: Array = [
		{"id": 1, "position": Vector2(12, 0)},
		{"id": 2, "position": Vector2(5, 0)},
		{"id": 3, "position": Vector2(30, 0)},
	]
	var selected := CombatEffects.select_nearest_targets(Vector2.ZERO, candidates, 20.0, 2)
	if selected.size() != 2:
		return _fail("chain/AOE target count failed")
	if int(selected[0]["id"]) != 2 or int(selected[1]["id"]) != 1:
		return _fail("nearest-target ordering failed")
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
