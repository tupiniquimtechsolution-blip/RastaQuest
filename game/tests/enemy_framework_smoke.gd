extends SceneTree

const EnemyBrain = preload("res://scripts/enemies/enemy_brain.gd")
const EncounterDirector = preload("res://scripts/enemies/encounter_director.gd")

func _init() -> void:
	if not _test_behavior_language():
		return
	if not _test_encounter_budget():
		return
	if not _test_twenty_minute_bounded_simulation():
		return
	print("RQ004_ENEMY_FRAMEWORK_OK")
	quit(0)

func _test_behavior_language() -> bool:
	var self_pos := Vector2.ZERO
	var target := Vector2(180, 0)

	var chaser := EnemyBrain.choose_intent("chaser", self_pos, target, 60.0, true)
	var ranged := EnemyBrain.choose_intent("ranged", self_pos, target, 220.0, true)
	var charger := EnemyBrain.choose_intent("charger", self_pos, target, 230.0, true)
	var controller := EnemyBrain.choose_intent("controller", self_pos, target, 190.0, true)
	var exploder := EnemyBrain.choose_intent("exploder", self_pos, Vector2(50, 0), 80.0, true)

	if float(chaser["move_axis"]) == 0.0:
		return _fail("chaser must close distance")
	if not bool(ranged["wants_attack"]):
		return _fail("ranged must attack in its band")
	if not bool(charger["wants_attack"]) or not bool(charger["high_threat"]):
		return _fail("charger high-threat intent failed")
	if not bool(controller["wants_attack"]) or float(controller["move_axis"]) != 0.0:
		return _fail("controller area-control intent failed")
	if not bool(exploder["wants_attack"]) or not bool(exploder["high_threat"]):
		return _fail("exploder contract failed")
	return true

func _test_encounter_budget() -> bool:
	var director := EncounterDirector.new(5, 1)
	if not director.register_enemy(1, 2, true):
		return _fail("first high-threat actor must register")
	if director.register_enemy(2, 2, true):
		return _fail("high-threat cap must reject second actor")
	if not director.register_enemy(3, 3, false):
		return _fail("remaining budget should accept normal actor")
	if director.register_enemy(4, 1, false):
		return _fail("budget overflow must be rejected")
	return true

func _test_twenty_minute_bounded_simulation() -> bool:
	var director := EncounterDirector.new(8, 2)

	for second in range(1200):
		var high := second % 4 == 0
		var cost := 2 if high else 1
		director.register_enemy(second, cost, high)

		if second >= 8:
			director.remove_enemy(second - 8)

		if director.active_budget() > 8:
			return _fail("stress simulation exceeded encounter budget")
		if director.high_threat_count() > 2:
			return _fail("stress simulation exceeded high-threat cap")
		if director.active_count() > 8:
			return _fail("stress simulation spawned without bound")

	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
