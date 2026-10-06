extends CharacterBody2D

signal attack_tell_started(pattern: StringName, duration: float)
signal boss_defeated

@export var target_path: NodePath
@onready var health: Node = $Health
@onready var visual: Polygon2D = $Visual

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
	var phase := 1 if ratio > 0.55 else 2
	var speed := 80.0 if phase == 1 else 125.0
	var distance := _target.global_position.x - global_position.x
	velocity.x = signf(distance) * speed if absf(distance) > 120.0 else 0.0
	velocity.y = minf(velocity.y + 1500.0 * delta, 900.0)

	if _cooldown <= 0.0:
		_cooldown = 1.5 if phase == 1 else 0.9
		var pattern: StringName = &"storm_slam" if phase == 1 else &"chain_burst"
		attack_tell_started.emit(pattern, 0.65 if phase == 1 else 0.4)

	move_and_slide()

func _on_died() -> void:
	boss_defeated.emit()
	queue_free()
