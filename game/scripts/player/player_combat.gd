extends Node

const CombatEffects = preload("res://scripts/combat/combat_effects.gd")

signal attack_state_changed(active: bool, animation_name: StringName)
signal electrical_proc_triggered(position: Vector2)

@export var ground_damage: int = 1
@export var air_damage: int = 1
@export var attack_window: float = 0.16
@export var attack_cooldown: float = 0.30
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

func _process(delta: float) -> void:
	_attack_remaining = maxf(_attack_remaining - delta, 0.0)
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)
	if _active_animation != &"" and _attack_remaining <= 0.0:
		_finish_attack()
	if Input.is_action_just_pressed("attack"):
		try_attack()

func try_attack() -> bool:
	if not body.can_attack() or _cooldown_remaining > 0.0 or _active_animation != &"":
		return false
	_attack_id += 1
	_attack_remaining = attack_window
	_cooldown_remaining = attack_cooldown
	var grounded := body.is_on_floor()
	_active_animation = &"attack_axe" if grounded else &"attack_axe_air"
	var damage := ground_damage if grounded else air_damage
	hitbox.position.x = 38.0 * body.facing_sign()
	hitbox.begin_attack(_attack_id, damage, &"axe")
	attack_state_changed.emit(true, _active_animation)
	return true

func current_attack_animation() -> StringName:
	return _active_animation

func cancel_attack() -> void:
	_attack_remaining = 0.0
	if _active_animation != &"":
		_finish_attack()

func reset_for_respawn() -> void:
	cancel_attack()
	_cooldown_remaining = 0.0

func _finish_attack() -> void:
	hitbox.end_attack()
	_active_animation = &""
	attack_state_changed.emit(false, &"")

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
