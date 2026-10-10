extends Area2D

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.anim_ctrl.play("portal_enter")
		await get_tree().create_timer(0.5).timeout
		GameManager.next_arena()
