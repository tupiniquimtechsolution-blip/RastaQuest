extends Area2D

signal hit_received(payload: Dictionary)

@export var health_path: NodePath
@onready var health: Node = get_node(health_path)

func _ready() -> void:
	if (collision_layer & 4) != 0:
		add_to_group("enemy_hurtbox")

func receive_hit(payload: Dictionary) -> bool:
	var amount: float = float(payload.get("amount", 0.0))
	var guard := get_parent().get_node_or_null("PlayerGuard")
	if guard != null:
		var response: Dictionary = guard.resolve_hit(payload)
		if response.parried:
			return true
		amount = response.amount
	var accepted: bool = health.take_damage(amount)
	if accepted:
		hit_received.emit(payload)
	return accepted
