extends RefCounted

enum State {
	IDLE,
	RUN,
	JUMP,
	FALL,
}

var current_state: int = State.IDLE

func resolve(on_floor: bool, motion: Vector2) -> int:
	var next_state: int

	if not on_floor:
		next_state = State.JUMP if motion.y < 0.0 else State.FALL
	elif absf(motion.x) > 1.0:
		next_state = State.RUN
	else:
		next_state = State.IDLE

	current_state = next_state
	return current_state

static func animation_name(state: int) -> StringName:
	match state:
		State.RUN:
			return &"run"
		State.JUMP:
			return &"jump"
		State.FALL:
			return &"fall"
		_:
			return &"idle"
