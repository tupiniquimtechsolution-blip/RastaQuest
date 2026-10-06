extends RefCounted

var _rng := RandomNumberGenerator.new()

func _init(seed_value: int = 1) -> void:
	_rng.seed = seed_value

func roll_electrical_proc(chance: float) -> bool:
	return _rng.randf() < clampf(chance, 0.0, 1.0)

static func select_nearest_targets(origin: Vector2, candidates: Array, radius: float, max_targets: int) -> Array:
	var valid: Array = []
	for candidate in candidates:
		var position: Vector2 = candidate.get("position", origin)
		var distance := origin.distance_to(position)
		if distance <= radius:
			valid.append({"id": candidate.get("id", -1), "position": position, "distance": distance})

	valid.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["distance"]) < float(b["distance"])
	)
	if max_targets <= 0:
		return []
	return valid.slice(0, mini(max_targets, valid.size()))
