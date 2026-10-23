extends Node2D

## One perfect counter per press; held defense protects every side of the body.
@export var perfect_window := 0.28
@export var push_speed := 360.0
var guarding := false
var _age := 0.0
var _cooldown := 0.0
var _feedback := 0.0
var _was_pressed := false
var _pending := 0.0
var _spent := false
@onready var body: CharacterBody2D = get_parent()

func _process(delta: float) -> void:
	_cooldown = maxf(0.0,_cooldown-delta)
	_feedback = maxf(0.0,_feedback-delta)
	_pending = maxf(0.0,_pending-delta)
	var pressed := Input.is_action_pressed("guard")
	if pressed and not _was_pressed:
		_pending = 0.20
		_spent = false
	_was_pressed = pressed
	if not pressed or body.health.dead or body._portal_entering:
		guarding = false
		_pending = 0.0
	elif not guarding and _pending>0.0 and can_raise():
		body.combat.cancel_attack()
		guarding = true
		_age = 0.0
		_pending = 0.0
	if guarding:
		_age += delta
	queue_redraw()

func can_raise() -> bool:
	return not body.health.dead and not body._portal_entering and body._hurt_remaining<=0.0 and (body.combat.current_attack_animation()==&"" or body.combat.phase==&"recovery")

func reset() -> void:
	guarding = false
	_age = 0.0
	_feedback = 0.0
	_pending = 0.0
	_was_pressed = Input.is_action_pressed("guard")

func resolve_hit(payload: Dictionary) -> Dictionary:
	var amount := float(payload.get("amount",0.0))
	if not guarding or body.health.dead or body._portal_entering:
		return {"amount":amount,"parried":false}
	var kind := String(payload.get("damage_type",""))
	var perfect := not _spent and _age<=perfect_window and _cooldown<=0.0
	var attack_id := int(payload.get("hostile_attack",0))
	var attack := instance_from_id(attack_id) as Node if attack_id>0 else null
	if kind in ["ranged","chain_burst","portal_burst"] and is_instance_valid(attack) and attack.has_method("reflect_projectile"):
		if attack.reflect_projectile(int(payload.get("projectile_index",-1)),body):
			_feedback = 0.20
			return {"amount":0.0,"parried":true}
	var source_id := int(payload.get("source",0))
	var attacker := instance_from_id(source_id) as Node2D if source_id>0 else null
	if perfect and kind in ["chaser","charger"] and is_instance_valid(attacker) and attacker.has_method("apply_parry_response"):
		_spent = true
		_cooldown = 0.22
		_feedback = 0.25
		var away := signf(attacker.global_position.x-body.global_position.x)
		if is_zero_approx(away):
			away = body.facing_sign()
		attacker.apply_parry_response(float(body.combat.ground_damage)*0.5,away,push_speed)
		return {"amount":0.0,"parried":true}
	return {"amount":amount*0.5,"parried":false}

func _draw() -> void:
	if guarding or _feedback>0.0:
		var color := Color(.35,.9,1,.8) if _feedback>0.0 else Color(.65,.9,1,.45)
		draw_circle(Vector2(0,-3),37,Color(color,.06))
		draw_arc(Vector2(0,-3),37,0,TAU,64,color,2.5,true)
