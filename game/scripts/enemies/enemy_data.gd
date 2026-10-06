extends Resource
class_name EnemyData

@export var display_name: String = "Enemy"
@export var behavior: String = "chaser"
@export var max_health: int = 3
@export var move_speed: float = 110.0
@export var attack_range: float = 70.0
@export var attack_cooldown: float = 1.0
@export var tell_seconds: float = 0.35
@export var encounter_cost: int = 1
@export var high_threat: bool = false
@export var visual_color: Color = Color(0.7, 0.2, 0.2, 1.0)
