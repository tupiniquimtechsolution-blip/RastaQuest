extends Node

@export var attack_damage := 10
@export var attack_cooldown := 0.4
@export var lightning_chance := 0.25
@export var lightning_bonus := 6

@onready var player := get_parent()
@onready var hitbox := player.get_node("AttackHitbox")
@onready var anim_ctrl := player.get_node("PlayerAnimations")

var can_attack := true

func attack(is_air := false):
	if not can_attack or player.is_dead:
		return

	can_attack = false
	player.lock_controls()

	if is_air:
		anim_ctrl.play("attack_axe_air")
	else:
		anim_ctrl.play("attack_axe")

	hitbox.damage = attack_damage
	hitbox.enable()

	await get_tree().create_timer(0.15).timeout
	hitbox.disable()

	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true
	player.unlock_controls()

func try_lightning() -> int:
	if randf() <= lightning_chance:
		anim_ctrl.play("lightning_proc")
		return lightning_bonus
	return 0
