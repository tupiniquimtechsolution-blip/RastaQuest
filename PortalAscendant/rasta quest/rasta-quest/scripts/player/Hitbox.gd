extends Area2D

var damage := 10

func enable():
	monitoring = true

func disable():
	monitoring = false

func _on_body_entered(body):
	if body.has_method("take_damage"):
		var combat := get_parent().get_node("PlayerCombat")
		var extra := combat.try_lightning()
		body.take_damage(damage + extra)
