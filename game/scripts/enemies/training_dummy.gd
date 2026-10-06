extends Node2D

@onready var health: Node = $Health
@onready var body_visual: Polygon2D = $Body

func _ready() -> void:
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)

func _on_damaged(_amount: int, remaining_health: int) -> void:
	var ratio := float(remaining_health) / float(health.max_health)
	body_visual.modulate = Color(1.0, maxf(ratio, 0.35), maxf(ratio, 0.35), 1.0)

func _on_died() -> void:
	visible = false
	set_process(false)
