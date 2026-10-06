extends CharacterBody2D

const EnemyBrain = preload("res://scripts/enemies/enemy_brain.gd")

signal attack_tell_started(behavior: String, duration: float)
signal enemy_defeated(enemy: Node)

@export var data: EnemyData
@export var target_path: NodePath

@onready var health: Node = $Health
@onready var visual: Polygon2D = $Visual

var _target: Node2D
var _attack_cooldown_remaining: float = 0.0

func _ready() -> void:
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

func _physics_process(delta: float) -> void:
	if health.dead:
		return

	_attack_cooldown_remaining = maxf(_attack_cooldown_remaining - delta, 0.0)
	velocity.y = minf(velocity.y + 1500.0 * delta, 900.0)

	if is_instance_valid(_target):
		var intent := EnemyBrain.choose_intent(
			data.behavior,
			global_position,
			_target.global_position,
			data.attack_range,
			_attack_cooldown_remaining <= 0.0
		)
		velocity.x = float(intent["move_axis"]) * data.move_speed

		if bool(intent["wants_attack"]):
			_attack_cooldown_remaining = data.attack_cooldown
			attack_tell_started.emit(data.behavior, data.tell_seconds * float(intent["tell_multiplier"]))
	else:
		velocity.x = move_toward(velocity.x, 0.0, data.move_speed * delta)

	move_and_slide()

func _on_died() -> void:
	enemy_defeated.emit(self)
	queue_free()
