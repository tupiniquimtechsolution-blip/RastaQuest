extends CharacterBody2D

const StateMachine = preload("res://scripts/player/player_state_machine.gd")

signal movement_state_changed(animation_name: StringName)

@export var move_speed: float = 260.0
@export var acceleration: float = 1800.0
@export var deceleration: float = 2200.0
@export var gravity_acceleration: float = 1500.0
@export var max_fall_speed: float = 900.0
@export var jump_velocity: float = -560.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.12

@onready var visual: Node2D = $Visual

var _spawn_position: Vector2
var _coyote_remaining: float = 0.0
var _jump_buffer_remaining: float = 0.0
var _facing: float = 1.0
var _state_machine := StateMachine.new()
var _last_animation: StringName = &"idle"

func _ready() -> void:
	_spawn_position = global_position
	_update_state()

func _physics_process(delta: float) -> void:
	_update_jump_windows(delta)
	_apply_horizontal_input(delta)
	_apply_gravity(delta)
	_try_jump()

	move_and_slide()
	_update_facing()
	_update_state()

func respawn() -> void:
	global_position = _spawn_position
	velocity = Vector2.ZERO
	_coyote_remaining = 0.0
	_jump_buffer_remaining = 0.0
	_update_state()

func current_animation_name() -> StringName:
	return _last_animation

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
	var state: int = _state_machine.resolve(is_on_floor(), velocity)
	var animation := StateMachine.animation_name(state)

	if animation == _last_animation:
		return

	_last_animation = animation
	movement_state_changed.emit(animation)
