extends RefCounted

var _attack_id: int = 0
var _hit_targets: Dictionary = {}

func begin_attack(attack_id: int) -> void:
	_attack_id = attack_id
	_hit_targets.clear()

func can_hit(target_id: int) -> bool:
	return not _hit_targets.has(target_id)

func mark_hit(target_id: int) -> void:
	_hit_targets[target_id] = _attack_id

func current_attack_id() -> int:
	return _attack_id
