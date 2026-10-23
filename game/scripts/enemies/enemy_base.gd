extends CharacterBody2D

const EnemyBrain = preload("res://scripts/enemies/enemy_brain.gd")
const HostileAttack = preload("res://scripts/combat/hostile_attack.gd")
const SpritePresenter = preload("res://scripts/enemies/enemy_sprite_presenter.gd")

signal attack_tell_started(behavior: String, duration: float)
signal enemy_defeated(enemy: Node)

@export var data: EnemyData
@export var target_path: NodePath
@export var sprite_frames: SpriteFrames

@onready var health: Node = $Health
@onready var visual: Polygon2D = $Visual

var _target: Node2D
var _attack_cooldown_remaining: float = 0.0
var _attack: Node2D
var _presenter: Node2D
var _parry_stun := 0.0
var _parry_push := 0.0
var _engaged := false

func _ready() -> void:
	add_to_group("hostile_actor")
	if data == null:
		push_error("EnemyBase requires EnemyData")
		set_physics_process(false)
		return

	health.max_health = data.max_health
	health.reset_health()
	health.died.connect(_on_died)
	visual.color = data.visual_color

	if not target_path.is_empty():
		_target = get_node_or_null(target_path) as Node2D
	if sprite_frames != null:
		apply_sprite_frames(sprite_frames)

func apply_sprite_frames(candidate: SpriteFrames) -> bool:
	if data == null or data.behavior != "chaser":
		return false
	if not is_instance_valid(_presenter):
		_presenter = SpritePresenter.new()
		_presenter.name = "SpritePresenter"
		add_child(_presenter)
	return _presenter.apply_frames(candidate)

func _physics_process(delta: float) -> void:
	if health.dead:
		return

	if is_instance_valid(_target) and absf(_target.global_position.x-global_position.x)<760.0:
		_engaged = true
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)
	velocity.y = minf(velocity.y + 1500.0 * delta, 900.0)

	if _parry_stun > 0.0:
		_parry_stun = maxf(0.0,_parry_stun-delta)
		velocity.x = _parry_push
		_parry_push = move_toward(_parry_push,0.0,1200.0*delta)
	elif not _engaged:
		velocity.x = 0.0
	elif is_instance_valid(_attack) and not _attack.is_queued_for_deletion():
		velocity.x = _attack.movement_velocity()
	elif is_instance_valid(_target):
		var intent := EnemyBrain.choose_intent(
			data.behavior,
			global_position,
			_target.global_position,
			data.attack_range,
			_attack_cooldown_remaining <= 0.0
		)
		velocity.x = float(intent["move_axis"]) * data.move_speed

		if bool(intent["wants_attack"]) and absf(_target.global_position.y-global_position.y)<70.0:
			var duration := data.tell_seconds * float(intent["tell_multiplier"])
			var attack := HostileAttack.new()
			add_child(attack)
			if attack.begin(self, _target, data.behavior, duration):
				_attack = attack
				_attack_cooldown_remaining = data.attack_cooldown
				velocity.x = 0.0
				attack_tell_started.emit(data.behavior, duration)
			else:
				attack.queue_free()
	else:
		velocity.x = move_toward(velocity.x, 0.0, data.move_speed * delta)

	move_and_slide()

func apply_parry_response(amount: float, facing: float, speed: float) -> void:
	if health.dead:
		return
	if is_instance_valid(_attack):
		_attack.cancel()
	_attack = null
	_parry_stun = 0.24
	_parry_push = facing*speed
	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining,0.65)
	health.take_damage(amount,true)

func _on_died() -> void:
	if is_instance_valid(_attack):
		_attack.cancel()
	var seconds: float = _presenter.death_presentation_seconds() if is_instance_valid(_presenter) else 0.0
	$CollisionShape2D.set_deferred("disabled", true)
	enemy_defeated.emit(self)
	if seconds > 0.0:
		await get_tree().create_timer(seconds,false).timeout
	if not is_inside_tree():
		return
	queue_free()
