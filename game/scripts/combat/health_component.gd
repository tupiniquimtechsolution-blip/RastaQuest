extends Node

signal damaged(amount: float, remaining_health: float)
signal health_changed
signal died

@export var max_health: int = 5
@export var invulnerability_seconds: float = 0.35

var health: float
var _invulnerability_remaining: float = 0.0
var dead: bool = false

func _ready() -> void:
	reset_health()

func _process(delta: float) -> void:
	_invulnerability_remaining = maxf(_invulnerability_remaining - delta, 0.0)

func reset_health() -> void:
	health = maxi(max_health, 1)
	_invulnerability_remaining = 0.0
	dead = false
	health_changed.emit()

func restore_full() -> void:
	reset_health()

func take_damage(amount: float, ignore_invulnerability: bool = false) -> bool:
	if dead or amount <= 0:
		return false
	if not ignore_invulnerability and _invulnerability_remaining > 0.0:
		return false

	health = maxf(health - amount, 0.0)
	_invulnerability_remaining = invulnerability_seconds
	damaged.emit(amount, health)
	health_changed.emit()

	if health == 0:
		dead = true
		died.emit()

	return true

func is_invulnerable() -> bool:
	return _invulnerability_remaining > 0.0

func heal_full() -> bool:
	if dead or health>=max_health:
		return false
	health = float(max_health)
	health_changed.emit()
	return true
