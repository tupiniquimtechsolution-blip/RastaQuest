extends RefCounted

var max_budget: int
var max_high_threat: int
var _active: Dictionary = {}
var _budget: int = 0
var _high_threat_count: int = 0

func _init(budget: int = 8, high_threat_cap: int = 2) -> void:
	max_budget = maxi(budget, 1)
	max_high_threat = maxi(high_threat_cap, 1)

func can_register(cost: int, high_threat: bool) -> bool:
	if cost <= 0:
		return false
	if _budget + cost > max_budget:
		return false
	if high_threat and _high_threat_count >= max_high_threat:
		return false
	return true

func register_enemy(enemy_id: int, cost: int, high_threat: bool) -> bool:
	if _active.has(enemy_id) or not can_register(cost, high_threat):
		return false
	_active[enemy_id] = {"cost": cost, "high_threat": high_threat}
	_budget += cost
	if high_threat:
		_high_threat_count += 1
	return true

func remove_enemy(enemy_id: int) -> void:
	if not _active.has(enemy_id):
		return
	var record: Dictionary = _active[enemy_id]
	_budget -= int(record["cost"])
	if bool(record["high_threat"]):
		_high_threat_count -= 1
	_active.erase(enemy_id)

func active_count() -> int:
	return _active.size()

func active_budget() -> int:
	return _budget

func high_threat_count() -> int:
	return _high_threat_count
