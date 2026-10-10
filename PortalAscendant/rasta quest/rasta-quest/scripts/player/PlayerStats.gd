extends Node

@export var max_life := 100
@export var invincibility_time := 0.6

var life := max_life
var invincible := false

@onready var player := get_parent()
@onready var anim_ctrl := player.get_node("PlayerAnimations")

func _ready():
	player.life = life
	player.life_changed.emit(life)

func take_damage(amount: int, knockback := Vector2.ZERO):
	if invincible or player.is_dead:
		return

	life -= amount
	player.life = life
	player.life_changed.emit(life)

	anim_ctrl.play("hurt")
	player.velocity += knockback

	invincible = true

	if life <= 0:
		player.die()
		return

	await get_tree().create_timer(invincibility_time).timeout
	invincible = false
