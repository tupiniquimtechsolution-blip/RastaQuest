extends Area2D

signal portal_entered

@onready var visual: Polygon2D = $Visual
var locked: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_locked(true)

func set_locked(value: bool) -> void:
	locked = value
	monitoring = not locked
	visual.modulate = Color(0.45, 0.45, 0.45, 1.0) if locked else Color(1.0, 1.0, 1.0, 1.0)

func _on_body_entered(body: Node2D) -> void:
	if locked:
		return
	if body.name == "Player":
		portal_entered.emit()
