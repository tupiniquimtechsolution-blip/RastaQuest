extends Node

signal damaged(amount: int, remaining_health: int)
signal died

@export var max_health: int = 5
@export var invulnerability_seconds: float = 0.35

var health: int
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

func restore_full() -> void:
	reset_health()

func take_damage(amount: int, ignore_invulnerability: bool = false) -> bool:
	if dead or amount <= 0:
		return false
	if not ignore_invulnerability and _invulnerability_remaining > 0.0:
		return false

	health = maxi(health - amount, 0)
	_invulnerability_remaining = invulnerability_seconds
	damaged.emit(amount, health)

	if health == 0:
		dead = true
		died.emit()

	return true

func is_invulnerable() -> bool:
	return _invulnerability_remaining > 0.0
