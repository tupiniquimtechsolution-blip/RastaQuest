extends Node

const CombatEffects = preload("res://scripts/combat/combat_effects.gd")

signal attack_state_changed(active: bool, animation_name: StringName)
signal electrical_proc_triggered(position: Vector2)

@export var ground_damage: int = 1
@export var air_damage: int = 1
@export var attack_window: float = 0.16
@export var attack_cooldown: float = 0.30
@export var windup_seconds := 0.05
@export var recovery_seconds := 0.09
var phase: StringName = &"idle"
var _pending_damage := 1
@export_range(0.0, 1.0, 0.01) var electrical_proc_chance: float = 0.25
@export var chain_lightning_enabled: bool = false
@export var on_kill_aoe_enabled: bool = false

@onready var body: CharacterBody2D = get_parent()
@onready var hitbox: Area2D = $"../AttackHitbox"

var _attack_id: int = 0
var _attack_remaining: float = 0.0
var _cooldown_remaining: float = 0.0
var _active_animation: StringName = &""
var _effects := CombatEffects.new(1337)

func _ready() -> void:
	hitbox.landed_hit.connect(_on_landed_hit)

var attack_facing := 1.0
var combo_index := 0
var _combo_grace := 0.0
var _input_buffer := 0.0

func _process(delta: float) -> void:
	_input_buffer = maxf(0.0,_input_buffer-delta)
	_combo_grace = maxf(0.0,_combo_grace-delta)
	_attack_remaining -= delta
	_cooldown_remaining = maxf(_cooldown_remaining-delta,0.0)
	while _active_animation!=&"" and _attack_remaining<=0.0:
		if phase==&"windup":
			phase = &"active"
			_attack_remaining += attack_window
			hitbox.begin_attack(_attack_id,_pending_damage,&"axe")
		elif phase==&"active":
			hitbox.end_attack()
			phase = &"recovery"
			_attack_remaining += recovery_seconds
		else:
			_finish_attack()
	if phase==&"active":
		var progress := clampf(1.0-_attack_remaining/attack_window,0.0,1.0)
		# A broad forward sweep; one hit per target remains authoritative.
		var vertical := lerpf(10.0,-24.0,progress) if combo_index==2 else lerpf(-24.0,10.0,progress)
		hitbox.position = Vector2((34.0+sin(progress*PI)*12.0)*attack_facing,vertical)
	if Input.is_action_just_pressed("attack"):
		request_attack()
	if _input_buffer>0.0 and _active_animation==&"" and _cooldown_remaining<=0.0:
		if try_attack():
			_input_buffer = 0.0

func request_attack() -> void:
	if try_attack():
		return
	if body.can_attack() and phase in [&"active",&"recovery"]:
		_input_buffer = 0.18

func try_attack() -> bool:
	if not body.can_attack() or _cooldown_remaining>0.0 or _active_animation!=&"":
		return false
	combo_index = (combo_index+1)%3 if _combo_grace>0.0 else 0
	_attack_id += 1
	phase = &"windup"
	_attack_remaining = windup_seconds
	_cooldown_remaining = attack_cooldown
	attack_facing = body.facing_sign()
	var grounded := body.is_on_floor()
	_active_animation = [&"attack_axe",&"attack_axe_2",&"attack_axe_3"][combo_index] if grounded else &"attack_axe_air"
	_pending_damage = ground_damage if grounded else air_damage
	hitbox.position = Vector2(34.0*attack_facing,-24)
	attack_state_changed.emit(true,_active_animation)
	return true

func current_attack_animation() -> StringName:
	return _active_animation

func cancel_attack() -> void:
	_input_buffer = 0.0
	_combo_grace = 0.0
	_attack_remaining = 0.0
	if _active_animation!=&"":
		_finish_attack()
	_combo_grace = 0.0

func reset_for_respawn() -> void:
	cancel_attack()
	_cooldown_remaining = 0.0
	combo_index = 0

func _finish_attack() -> void:
	hitbox.end_attack()
	phase = &"idle"
	_active_animation = &""
	_combo_grace = 0.65
	attack_state_changed.emit(false,&"")

func _on_landed_hit(target: Area2D, _payload: Dictionary) -> void:
	get_node("/root/ArtCatalog").burst("hit",target.global_position,body,48,.18)
	var proc := _effects.roll_electrical_proc(electrical_proc_chance)
	if proc:
		electrical_proc_triggered.emit(target.global_position)
		get_node("/root/ArtCatalog").burst("electric_chain",body.global_position,body,64,.18,target.global_position)
		if chain_lightning_enabled:
			_apply_secondary_damage(target, target.global_position, 180.0, 2, 1, &"lightning")

	if on_kill_aoe_enabled and target.health.dead:
		get_node("/root/ArtCatalog").burst("electric_onkill",target.global_position,body,280,.24)
		_apply_secondary_damage(target, target.global_position, 140.0, 4, 1, &"on_kill_aoe")

func _apply_secondary_damage(origin_target: Area2D, origin: Vector2, radius: float, max_targets: int, amount: int, damage_type: StringName) -> void:
	var candidates: Array = []
	var nodes := get_tree().get_nodes_in_group("enemy_hurtbox")
	for node in nodes:
		if node == origin_target or not is_instance_valid(node):
			continue
		candidates.append({"id": node.get_instance_id(), "position": node.global_position, "node": node})

	var selected := CombatEffects.select_nearest_targets(origin, candidates, radius, max_targets)
	for entry in selected:
		var node: Area2D = entry.get("node") as Area2D
		if is_instance_valid(node):
			var accepted: bool = node.receive_hit({"attack_id": _attack_id, "amount": amount, "damage_type": damage_type, "source": body.get_instance_id()})
			if accepted:
				get_node("/root/ArtCatalog").burst("electric_chain" if damage_type==&"lightning" else "electric_area",origin,body,64 if damage_type==&"lightning" else radius*2,.20,node.global_position if damage_type==&"lightning" else Vector2.INF)
