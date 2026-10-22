extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _check(ok: bool, message: String) -> bool:
	if not ok:
		push_error(message)
		quit(1)
	return ok

func _run() -> void:
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_forest_polish.json","user://rq_forest_polish.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("RunManager").start_run(424242)
	var room: Node = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	room._clear_enemies()
	var art: Script = load("res://tests/art_review_fixtures.gd")
	art.assign(room.player,room.portal)
	var fixture: Script = load("res://tests/forest_polish_fixture.gd")
	var enemy: CharacterBody2D = fixture.build(room)
	var presenter: Node = enemy.get_node("SpritePresenter")
	var sprite: AnimatedSprite2D = presenter.get_node("EnemySprite")
	var equipment: Node2D = sprite.get_node("RigidEquipment")
	var sword: Sprite2D = equipment.get_node("sword")
	var shield: Sprite2D = equipment.get_node("shield")
	var sword_id := sword.texture.get_instance_id()
	var shield_id := shield.texture.get_instance_id()
	enemy.set_physics_process(false)
	presenter.set_process(false)
	for clip in [&"idle",&"move",&"tell",&"attack",&"hurt",&"death"]:
		for index in range(sprite.sprite_frames.get_frame_count(clip)):
			for mirrored in [false,true]:
				sprite.animation = clip
				sprite.frame = index
				sprite.flip_h = mirrored
				presenter._sync_equipment()
				if not _check(sword.texture.get_instance_id()==sword_id and shield.texture.get_instance_id()==shield_id and equipment.scale.x==(-1.0 if mirrored else 1.0),"Equipment changed shape or did not mirror with body"):
					return
	var valid_keys: Dictionary = presenter._equipment_keys.duplicate(true)
	var invalid_keys := valid_keys.duplicate(true)
	invalid_keys["attack"][0]["sword_position"] = [INF,0]
	if not _check(not presenter.apply_equipment(sword.texture,shield.texture,invalid_keys) and is_instance_valid(equipment),"Malformed rig mutated a valid presentation"):
		return
	var sword_texture := sword.texture
	var shield_texture := shield.texture
	presenter.apply_frames(fixture.chaser_frames())
	if not _check(not is_instance_valid(equipment) and presenter.apply_equipment(sword_texture,shield_texture,valid_keys),"Body rebind retained stale equipment hand keys"):
		return
	presenter.set_process(true)
	enemy.position = Vector2(685,611)
	room.player.position = Vector2(640,614)
	enemy.set_physics_process(true)
	var seen := {}
	for _i in range(50):
		await physics_frame
		await process_frame
		seen[sprite.animation] = true
	if not _check(seen.has(&"tell") and seen.has(&"attack") and room.player.health.health<5,"Polished clips broke actual hostile attack damage"):
		return
	enemy.get_node("Health").take_damage(1000,true)
	await create_timer(.10).timeout
	if not _check(is_instance_valid(enemy) and room._alive_enemies==0 and room.get_node("Enemies/HostileAttackBudget").active_count()==0,"Death failed cancellation/progress"):
		return
	await create_timer(.30).timeout
	if not _check(not is_instance_valid(enemy) and not room.portal.locked,"Bounded death/portal failed"):
		return
	for landing in [Vector2(401,576),Vector2(527,576),Vector2(833,512),Vector2(959,512)]:
		room.player.position = landing-Vector2(0,60)
		room.player.velocity = Vector2.ZERO
		for _i in range(30):
			await physics_frame
		if not _check(room.player.is_on_floor() and absf(room.player.position.y+26-landing.y)<1.0,"Painted platform edge/top lost collision alignment"):
			return
	var camera: Camera2D = room.player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = 2560
	camera.position.y = -154
	room.player.respawn()
	room.player.position = Vector2(180,614)
	camera.reset_smoothing()
	for _i in range(3):
		await physics_frame
	camera.force_update_scroll()
	var layers: Node2D = room.get_node("ForestPolishLayers")
	layers.update_layers()
	var first_center := camera.get_screen_center_position()
	var first_far: float = layers.far_layer.position.x
	var first_mid: float = layers.mid_layer.position.x
	room.portal.set_locked(true) # Traversal inspection must not enter reward selection.
	Input.action_press("move_right")
	var floor_misses := 0
	var jumped := false
	for _i in range(550):
		Input.action_release("jump")
		if room.player.position.x>330 and not jumped:
			Input.action_press("jump")
			jumped = true
		await physics_frame
		if room.player.position.x>1340 and not room.player.is_on_floor():
			floor_misses += 1
		if room.player.position.x>=2360:
			break
	Input.action_release("move_right")
	Input.action_release("jump")
	camera.reset_smoothing()
	camera.force_update_scroll()
	layers.update_layers()
	var delta := camera.get_screen_center_position().x-first_center.x
	if not _check(room.player.position.x>=2360 and floor_misses==0 and delta>1000,"Traversal failed x=%s floor_misses=%s camera_delta=%s"%[room.player.position.x,floor_misses,delta]):
		return
	if not _check(absf((layers.far_layer.position.x-first_far)-delta*.75)<2.0 and absf((layers.mid_layer.position.x-first_mid)-delta*.35)<2.0,"Parallax layer speeds do not match real camera movement"):
		return
	for x in [180,640,1280,1920,2380]:
		room.player.position.x = x
		camera.reset_smoothing()
		camera.force_update_scroll()
		layers.update_layers()
		var center := camera.get_screen_center_position()
		var left: float = layers._backgrounds[0].global_position.x
		var right: float = layers._backgrounds[-1].global_position.x+1280
		if not _check(left<=center.x-640 and right>=center.x+640 and layers.far_layer.position.y<=center.y-360 and layers.far_layer.position.y+720>=center.y+359,"Background coverage gap at traversal checkpoint"):
			return
	print("RQ_FOREST_POLISH_OK poses16 equipment=rigid_mirrored platform_edges4=aligned traversal=2180px parallax=actual_camera coverage5=pass")
	room.queue_free()
	await process_frame
	quit(0)
