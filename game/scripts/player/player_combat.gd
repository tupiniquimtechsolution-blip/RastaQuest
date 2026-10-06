extends Node

const CombatEffects = preload("res://scripts/combat/combat_effects.gd")

signal attack_state_changed(active: bool, animation_name: StringName)
signal electrical_proc_triggered(position: Vector2)

@export var ground_damage: int = 1
@export var air_damage: int = 1
@export var attack_window: float = 0.16
@export var attack_cooldown: float = 0.30
@export_range(0.0, 1.0, 0.01) var electrical_proc_chance: float = 0.25

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
	if _cooldown_remaining > 0.0 or _active_animation != &"":
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

func _finish_attack() -> void:
	hitbox.end_attack()
	_active_animation = &""
	attack_state_changed.emit(false, &"")

func _on_landed_hit(target: Area2D, _payload: Dictionary) -> void:
	if _effects.roll_electrical_proc(electrical_proc_chance):
		electrical_proc_triggered.emit(target.global_position)
