extends Node

@onready var player := get_parent()
@onready var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func play(name: String):
	if sprite.animation != name:
		sprite.play(name)

func update_animation(vel: Vector2, attacking: bool):
	if player.is_dead:
		return

	if attacking:
		return

	if not player.is_on_floor():
		if vel.y < 0:
			play("jump")
		else:
			play("fall")
	elif abs(vel.x) > 5:
		play("run")
	else:
		play("idle")
