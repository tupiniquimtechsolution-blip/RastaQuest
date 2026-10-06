extends CharacterBody2D

const StateMachine = preload("res://scripts/player/player_state_machine.gd")
const CombatStatePriority = preload("res://scripts/combat/combat_state_priority.gd")

signal movement_state_changed(animation_name: StringName)

@export var move_speed: float = 260.0
@export var acceleration: float = 1800.0
@export var deceleration: float = 2200.0
@export var gravity_acceleration: float = 1500.0
@export var max_fall_speed: float = 900.0
@export var jump_velocity: float = -560.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12
@export var hurt_lock_seconds: float = 0.18

@onready var visual: Node2D = $Visual
@onready var health: Node = $Health
@onready var combat: Node = $PlayerCombat

var _spawn_position: Vector2
var _coyote_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0
var _facing: float = 1.0
var _state_machine := StateMachine.new()
var _last_animation: StringName = &"idle"
var _hurt_remaining: float = 0.0
var _dead: bool = false
var _attack_animation: StringName = &""

func _ready() -> void:
	_spawn_position = global_position
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	combat.attack_state_changed.connect(_on_attack_state_changed)
	_update_state()

func _physics_process(delta: float) -> void:
	_hurt_remaining = maxf(_hurt_remaining - delta, 0.0)

	if _dead:
		velocity = Vector2.ZERO
		_update_state()
		return

	_update_jump_windows(delta)
	if _hurt_remaining <= 0.0:
		_apply_horizontal_input(delta)
		_try_jump()
	else:
		velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

	_apply_gravity(delta)
	move_and_slide()
	_update_facing()
	_update_state()

func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	_coyote_remaining = 0.0
	_jump_buffer_remaining = 0.0
	_hurt_remaining = 0.0
	_dead = false
	_attack_animation = &""
	health.restore_full()
	visible = true
	_update_state()

func current_animation_name() -> StringName:
	return _last_animation

func facing_sign() -> float:
	return _facing

func _update_jump_windows(delta: float) -> void:
	if is_on_floor():
		_coyote_remaining = coyote_time
	else:
		_coyote_remaining = maxf(_coyote_remaining - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		_jump_buffer_remaining = jump_buffer_time
	else:
		_jump_buffer_remaining = maxf(_jump_buffer_remaining - delta, 0.0)

func _apply_horizontal_input(delta: float) -> void:
	var axis := Input.get_axis("move_left", "move_right")
	var target_speed := axis * move_speed
	var rate := acceleration if not is_zero_approx(axis) else deceleration
	velocity.x = move_toward(velocity.x, target_speed, rate * delta)

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + gravity_acceleration * delta, max_fall_speed)

func _try_jump() -> void:
	if _jump_buffer_remaining > 0.0 and _coyote_remaining > 0.0:
		velocity.y = jump_velocity
		_jump_buffer_remaining = 0.0
		_coyote_remaining = 0.0

func _update_facing() -> void:
	if velocity.x > 1.0:
		_facing = 1.0
	elif velocity.x < -1.0:
		_facing = -1.0
	visual.scale.x = absf(visual.scale.x) * _facing

func _update_state() -> void:
	_state_machine.resolve(is_on_floor(), velocity)
	var animation := CombatStatePriority.resolve(
		_dead,
		_hurt_remaining > 0.0,
		_attack_animation,
		is_on_floor(),
		velocity
	)

	if animation == _last_animation:
		return

	_last_animation = animation
	movement_state_changed.emit(animation)

func _on_damaged(_amount: int, _remaining_health: int) -> void:
	_hurt_remaining = hurt_lock_seconds
	_update_state()

func _on_died() -> void:
	_dead = true
	_attack_animation = &""
	_update_state()

func _on_attack_state_changed(active: bool, animation_name: StringName) -> void:
	_attack_animation = animation_name if active else &""
	_update_state()
