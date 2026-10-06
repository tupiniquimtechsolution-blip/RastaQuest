extends Area2D

signal hit_received(payload: Dictionary)

@export var health_path: NodePath

@onready var health: Node = get_node(health_path)

func receive_hit(payload: Dictionary) -> bool:
	var amount: int = int(payload.get("amount", 0))
	var accepted: bool = health.take_damage(amount)
	if accepted:
		hit_received.emit(payload)
	return accepted
