extends Node

# One budget per encounter container; leases cover actual tells/attacks/recovery.
const MAX_ATTACKS := 4
const MAX_HIGH_THREAT := 2
var _leases: Dictionary = {}

func acquire(attack_id: int, high_threat: bool) -> bool:
	if _leases.has(attack_id) or _leases.size() >= MAX_ATTACKS:
		return false
	if high_threat and high_threat_count() >= MAX_HIGH_THREAT:
		return false
	_leases[attack_id] = high_threat
	return true

func release(attack_id: int) -> void:
	_leases.erase(attack_id)

func high_threat_count() -> int:
	var count := 0
	for high: bool in _leases.values():
		if high:
			count += 1
	return count

func active_count() -> int:
	return _leases.size()
