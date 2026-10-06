extends RefCounted

static func resolve(is_dead: bool, is_hurt: bool, attack_animation: StringName, on_floor: bool, motion: Vector2) -> StringName:
	if is_dead:
		return &"death"
	if is_hurt:
		return &"hurt"
	if attack_animation != &"":
		return attack_animation
	if not on_floor:
		return &"jump" if motion.y < 0.0 else &"fall"
	if absf(motion.x) > 1.0:
		return &"run"
	return &"idle"
