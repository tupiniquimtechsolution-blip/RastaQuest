extends SceneTree

## Synthetic frame fixtures only, excluded from store exports; not production art.
func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var scene: PackedScene = load("res://scenes/player/Player.tscn")
	var player := scene.instantiate()
	root.add_child(player)
	await process_frame
	var visual: Node2D = player.get_node("Visual")
	var original_shape: Vector2 = player.get_node("CollisionShape2D").shape.size
	if not visual.get_node("Body").visible or visual.apply_frames(SpriteFrames.new()):
		_fail("missing art must keep development visual")
		return
	var frames := SpriteFrames.new()
	var texture := ImageTexture.create_from_image(Image.create(256, 256, false, Image.FORMAT_RGBA8))
	for clip in visual.BODY_CLIPS:
		frames.add_animation(clip)
		frames.add_frame(clip, texture)
	if not visual.apply_frames(frames):
		_fail("valid complete frame contract was rejected")
		return
	var sprite: AnimatedSprite2D = visual.get_node("ProductionSprite")
	if visual.get_node("Body").visible or not sprite.visible or sprite.scale != Vector2(0.5, 0.5):
		_fail("source2x must render at half scale")
		return
	if sprite.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST or not sprite.centered:
		_fail("sprite sampling or origin differs from contract")
		return
	for clip in visual.BODY_CLIPS:
		player.movement_state_changed.emit(clip)
		if sprite.animation != clip:
			_fail("movement/combat state did not reach the sprite")
			return
	player.velocity.x = -20.0
	player._update_facing()
	if visual.scale.x != -1.0 or sprite.scale != Vector2(0.5, 0.5):
		_fail("facing changed source density")
		return
	var wrong := frames.duplicate(true) as SpriteFrames
	wrong.set_frame(&"idle", 0, ImageTexture.create_from_image(Image.create(128, 128, false, Image.FORMAT_RGBA8)))
	if visual.apply_frames(wrong) or sprite.sprite_frames != frames:
		_fail("invalid frame must not replace the working set")
		return
	# Receive real Health/Combat signals through the actual Player controller.
	player.get_node("Health").damaged.emit(1, 4)
	if sprite.animation != &"hurt":
		_fail("real damage signal did not select hurt")
		return
	player.get_node("Health").died.emit()
	if sprite.animation != &"death" or player.get_node("CollisionShape2D").shape.size != original_shape:
		_fail("death signal or invariant collision geometry failed")
		return
	player.queue_free()
	await process_frame
	print("RQ_PLAYER_SPRITE_OK density=2 scale=0.5 body_clips=8 assets=synthetic-only")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
