extends CharacterBody2D

signal attack_tell_started(pattern: StringName, duration: float)
signal boss_defeated

@export var target_path: NodePath
@onready var health: Node = $Health

var _target: Node2D
var _cooldown: float = 0.0

func _ready() -> void:
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
	if _cooldown <= 0.0:
		_cooldown = maxf(0.55, 1.35 - 0.25 * float(phase - 1))
		var patterns: Array[StringName] = [&"rift_slam", &"portal_burst", &"fracture_storm"]
		attack_tell_started.emit(patterns[phase - 1], maxf(0.28, 0.60 - 0.12 * float(phase - 1)))
	move_and_slide()

func _on_died() -> void:
	boss_defeated.emit()
	queue_free()
