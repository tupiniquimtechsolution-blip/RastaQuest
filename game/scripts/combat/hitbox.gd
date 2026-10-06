extends Area2D

const AttackRegistry = preload("res://scripts/combat/attack_registry.gd")

signal landed_hit(target: Area2D, payload: Dictionary)

var _registry := AttackRegistry.new()
var _payload: Dictionary = {}
var _active: bool = false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	monitoring = false

func begin_attack(attack_id: int, amount: int, damage_type: StringName) -> void:
	_registry.begin_attack(attack_id)
	_payload = {
		"attack_id": attack_id,
		"amount": amount,
		"damage_type": damage_type,
		"source": get_parent().get_instance_id(),
	}
	_active = true
	monitoring = true

func end_attack() -> void:
	_active = false
	monitoring = false

func _on_area_entered(area: Area2D) -> void:
	if not _active or not area.has_method("receive_hit"):
		return
	var target_id := area.get_instance_id()
	if not _registry.can_hit(target_id):
		return
	_registry.mark_hit(target_id)
	var accepted: bool = bool(area.call("receive_hit", _payload))
	if accepted:
		landed_hit.emit(area, _payload)
