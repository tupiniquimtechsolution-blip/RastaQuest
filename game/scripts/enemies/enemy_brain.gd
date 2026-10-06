extends RefCounted

static func choose_intent(behavior: String, self_position: Vector2, target_position: Vector2, attack_range: float, cooldown_ready: bool) -> Dictionary:
	var delta := target_position - self_position
	var distance := absf(delta.x)
	var toward := signf(delta.x)
	var intent := {
		"move_axis": 0.0,
		"wants_attack": false,
		"high_threat": false,
		"tell_multiplier": 1.0,
	}

	match behavior:
		"chaser":
			intent["move_axis"] = toward if distance > attack_range else 0.0
			intent["wants_attack"] = cooldown_ready and distance <= attack_range
		"ranged":
			if distance < attack_range * 0.75:
				intent["move_axis"] = -toward
			elif distance > attack_range * 1.6:
				intent["move_axis"] = toward
			intent["wants_attack"] = cooldown_ready and distance >= attack_range * 0.75 and distance <= attack_range * 1.6
		"charger":
			intent["move_axis"] = toward
			intent["wants_attack"] = cooldown_ready and distance <= attack_range
			intent["high_threat"] = bool(intent["wants_attack"])
			intent["tell_multiplier"] = 1.35
		"controller":
			intent["move_axis"] = 0.0 if distance <= attack_range else toward * 0.35
			intent["wants_attack"] = cooldown_ready and distance <= attack_range
			intent["high_threat"] = bool(intent["wants_attack"])
			intent["tell_multiplier"] = 1.5
		"exploder":
			intent["move_axis"] = toward
			intent["wants_attack"] = cooldown_ready and distance <= attack_range
			intent["high_threat"] = bool(intent["wants_attack"])
			intent["tell_multiplier"] = 1.75
		_:
			intent["move_axis"] = toward

	return intent
