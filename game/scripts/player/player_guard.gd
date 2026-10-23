extends Node2D

## A fresh frontal defense has a bounded perfect window; holding never re-arms it.
@export var perfect_window := 0.14
@export var push_speed := 360.0
var guarding := false
var _age := 0.0
var _cooldown := 0.0
var _feedback := 0.0
@onready var body: CharacterBody2D = get_parent()

func _process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown-delta)
	_feedback = maxf(0.0, _feedback-delta)
	if not Input.is_action_pressed("guard") or not can_raise():
		guarding = false
	elif Input.is_action_just_pressed("guard") and _cooldown <= 0.0:
		guarding = true
		_age = 0.0
	if guarding:
		_age += delta
	queue_redraw()

func can_raise() -> bool:
	return not body.health.dead and not body._portal_entering and body._hurt_remaining <= 0.0 and body.combat.current_attack_animation() == &""

func reset() -> void:
	guarding = false
	_age = 0.0
	_feedback = 0.0

func resolve_hit(payload: Dictionary) -> Dictionary:
	var amount := float(payload.get("amount",0.0))
	if not guarding or not can_raise() or String(payload.get("damage_type","")) not in ["chaser","charger"]:
		return {"amount": amount, "parried": false}
	var source_id := int(payload.get("source",0))
	var attacker := instance_from_id(source_id) as Node2D if source_id > 0 else null
	if not is_instance_valid(attacker) or not attacker.has_method("apply_parry_response"):
		return {"amount": amount, "parried": false}
	var offset := attacker.global_position.x-body.global_position.x
	if offset*body.facing_sign() < 0.0:
		return {"amount": amount, "parried": false}
	if _age <= perfect_window and _cooldown <= 0.0:
		_cooldown = 0.4
		guarding = false
		_feedback = 0.22
		attacker.apply_parry_response(float(body.combat.ground_damage)*0.5, body.facing_sign(), push_speed)
		return {"amount": 0.0, "parried": true}
	return {"amount": amount*0.5, "parried": false}

func _draw() -> void:
	if guarding or _feedback > 0.0:
		var at := Vector2(body.facing_sign()*24.0,-6.0)
		draw_arc(at,32.0,-PI*0.5 if body.facing_sign()>0 else PI*0.5,PI*0.5 if body.facing_sign()>0 else PI*1.5,24,Color(.35,.9,1,.8) if _feedback>0.0 else Color(.7,.9,1,.45),3.0,true)
