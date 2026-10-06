extends SceneTree

const StateMachine = preload("res://scripts/player/player_state_machine.gd")
const InputDefaults = preload("res://scripts/core/input_defaults.gd")

func _init() -> void:
	InputDefaults.ensure_defaults()

	for action: StringName in InputDefaults.REQUIRED_ACTIONS:
		if InputMap.action_get_events(action).is_empty():
			push_error("Missing development input event for action: %s" % action)
			quit(1)
			return

	var machine := StateMachine.new()

	for cycle in range(100):
		if not _expect(machine.resolve(true, Vector2.ZERO), StateMachine.State.IDLE, cycle, "idle"):
			return
		if not _expect(machine.resolve(true, Vector2(240.0, 0.0)), StateMachine.State.RUN, cycle, "run"):
			return
		if not _expect(machine.resolve(false, Vector2(240.0, -500.0)), StateMachine.State.JUMP, cycle, "jump"):
			return
		if not _expect(machine.resolve(false, Vector2(240.0, 500.0)), StateMachine.State.FALL, cycle, "fall"):
			return
		if not _expect(machine.resolve(true, Vector2.ZERO), StateMachine.State.IDLE, cycle, "landing"):
			return

	print("RQ002_PLAYER_STATE_OK cycles=100")
	quit(0)

func _expect(actual: int, expected: int, cycle: int, label: String) -> bool:
	if actual == expected:
		return true

	push_error("State mismatch cycle=%d label=%s expected=%d actual=%d" % [cycle, label, expected, actual])
	quit(1)
	return false
