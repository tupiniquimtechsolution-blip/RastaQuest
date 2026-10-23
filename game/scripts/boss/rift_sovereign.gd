extends CharacterBody2D

const HostileAttack = preload("res://scripts/combat/hostile_attack.gd")

signal attack_tell_started(pattern: StringName, duration: float)
signal boss_defeated

@export var target_path: NodePath
@onready var health: Node = $Health

var _target: Node2D
var _cooldown: float = 0.0
var _attack: Node2D
var _art_presenter: Node2D

func apply_art_frames(frames: SpriteFrames, patterns: Dictionary) -> bool:
	if not is_instance_valid(_art_presenter):
		_art_presenter = preload("res://scripts/enemies/hostile_art_presenter.gd").new()
		_art_presenter.name = "ArtPresenter"
		add_child(_art_presenter)
	return _art_presenter.apply_frames(frames,patterns,512)

func _ready() -> void:
	add_to_group("hostile_actor")
	health.died.connect(_on_died)
	_target = get_node_or_null(target_path) as Node2D

func _physics_process(delta: float) -> void:
	if health.dead or not is_instance_valid(_target):
		return
	_cooldown = maxf(_cooldown - delta, 0.0)
	var ratio := float(health.health) / float(health.max_health)
	var phase := 1 if ratio > 0.66 else (2 if ratio > 0.33 else 3)
	var speed := 90.0 + 35.0 * float(phase - 1)
	var distance := _target.global_position.x - global_position.x
	velocity.x = signf(distance) * speed if absf(distance) > 115.0 else 0.0
	velocity.y = minf(velocity.y + 1500.0 * delta, 900.0)
	if is_instance_valid(_attack) and not _attack.is_queued_for_deletion():
		velocity.x = _attack.movement_velocity()
	elif _cooldown <= 0.0:
		var patterns: Array[StringName] = [&"rift_slam", &"portal_burst", &"fracture_storm"]
		var pattern: StringName = patterns[phase - 1]
		var duration := maxf(0.28, 0.60 - 0.12 * float(phase - 1))
		var attack := HostileAttack.new()
		add_child(attack)
		if attack.begin(self, _target, String(pattern), duration):
			_attack = attack
			_cooldown = maxf(0.55, 1.35 - 0.25 * float(phase - 1))
			velocity.x = 0.0
			attack_tell_started.emit(pattern, duration)
		else:
			attack.queue_free()
	move_and_slide()

func _on_died() -> void:
	if is_instance_valid(_attack):
		_attack.cancel()
	var seconds: float = _art_presenter.death_presentation_seconds() if is_instance_valid(_art_presenter) else 0.0
	$CollisionShape2D.set_deferred("disabled",true)
	boss_defeated.emit()
	if seconds>0:
		await get_tree().create_timer(seconds,false).timeout
	if not is_inside_tree():
		return
	queue_free()
