extends "res://../tools/render_art_room_review.gd"

var _pose_inspection := false

func _capture(name: String) -> void:
	await super._capture(name)
	var record: Dictionary = _records[-1]
	var camera: Camera2D = current_scene.player.get_node("Camera2D")
	var center := camera.get_screen_center_position()
	record.camera_center = [center.x,center.y]
	record.player_position = [current_scene.player.position.x,current_scene.player.position.y]
	record.pose_inspection = _pose_inspection
	record.far_position = [current_scene.get_node("ForestPolishLayers").far_layer.position.x,current_scene.get_node("ForestPolishLayers").far_layer.position.y]
	if is_instance_valid(_enemy):
		var sprite: AnimatedSprite2D = _enemy.get_node("SpritePresenter/EnemySprite")
		record.enemy_dead = _enemy.get_node("Health").dead
		record.enemy_frame = sprite.frame
		record.mirrored = sprite.flip_h
		record.rigid_sword_sha256 = FileAccess.get_sha256("res://../assets/production_drafts/2026-10-22/forest-chaser-polish/chaser_sword.png")
		record.rigid_shield_sha256 = FileAccess.get_sha256("res://../assets/production_drafts/2026-10-22/forest-chaser-polish/chaser_shield.png")

func _run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Desktop renderer required")
		quit(1)
		return
	_output = ProjectSettings.globalize_path("res://../assets/production_drafts/2026-10-22/forest-chaser-polish/room-review")
	DirAccess.make_dir_recursive_absolute(_output)
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_render_polish.json","user://rq_render_polish.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("SettingsManager").reload_from_save()
	root.get_node("RunManager").start_run(424242)
	var room: Node = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	room._clear_enemies()
	var art: Script = load("res://tests/art_review_fixtures.gd")
	art.assign(room.player,room.portal)
	_enemy = load("res://tests/forest_polish_fixture.gd").build(room)
	_enemy.set_physics_process(false)
	var player: CharacterBody2D = room.player
	player.position = Vector2(640,614)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = 2560
	camera.position.y = -154
	room.status_label.text = "FLORESTA / CHASER v02 • PROVA VISUAL • enquadramento proposto"
	for _i in range(20):
		await physics_frame
	player.set_physics_process(false)
	for x in [180,640,1280,1920,2380]:
		player.position = Vector2(x,614)
		_enemy.position = Vector2(x+140,611)
		camera.reset_smoothing()
		camera.force_update_scroll()
		for size in [Vector2i(1280,720),Vector2i(640,360)]:
			root.size = size
			await _capture("traverse_%04d_%dx%d"%[x,size.x,size.y])
	root.size = Vector2i(1280,720)
	player.position = Vector2(640,614)
	_enemy.position = Vector2(685,611)
	camera.reset_smoothing()
	_enemy._physics_process(0.0)
	await process_frame
	await process_frame
	paused = true
	await _capture("actual_tell_1280x720")
	paused = false
	await create_timer(.27).timeout
	paused = true
	await _capture("actual_active_1280x720")
	paused = false
	if is_instance_valid(_enemy._attack):
		_enemy._attack.cancel()
	await create_timer(.25).timeout
	player.respawn()
	player.position = Vector2(640,614)
	var presenter: Node = _enemy.get_node("SpritePresenter")
	var sprite: AnimatedSprite2D = presenter.get_node("EnemySprite")
	presenter.set_process(false)
	_pose_inspection = true
	_enemy.position = Vector2(800,611)
	for clip in [&"idle",&"move",&"tell",&"attack",&"hurt",&"death"]:
		for index in range(sprite.sprite_frames.get_frame_count(clip)):
			sprite.animation = clip
			sprite.frame = index
			sprite.pause()
			sprite.flip_h = false
			presenter._sync_equipment()
			root.size = Vector2i(640,360)
			await _capture("pose_%s_%02d_640x360"%[clip,index+1])
	for mirrored in [false,true]:
		sprite.animation = &"attack"
		sprite.frame = 0
		sprite.flip_h = mirrored
		presenter._sync_equipment()
		root.size = Vector2i(1280,720)
		await _capture("rig_attack_"+("right" if mirrored else "left"))
	_pose_inspection = false
	presenter.set_process(true)
	_enemy.get_node("Health").take_damage(1000,true)
	var saw_fallen := false
	for _i in range(30):
		await process_frame
		if not is_instance_valid(_enemy):
			break
		if sprite.animation == &"death" and sprite.frame == 1:
			saw_fallen = true
			break
	if not saw_fallen:
		push_error("Renderer missed actual fallen death key before bounded cleanup")
		quit(1)
		return
	paused = true
	await _capture("actual_death_1280x720")
	paused = false
	var hashes := {}
	for source in ["res://scripts/enemies/enemy_sprite_presenter.gd","res://scripts/enemies/enemy_base.gd","res://scripts/combat/hostile_attack.gd","res://scripts/player/player_controller.gd","res://scripts/player/player_sprite_presenter.gd","res://tests/art_review_fixtures.gd","res://tests/forest_review_fixture.gd","res://tests/forest_polish_fixture.gd","res://tests/forest_review_parallax.gd","res://../tools/render_forest_polish_review.gd","res://../tools/render_art_room_review.gd","res://../assets/production_drafts/2026-10-22/forest-chaser-polish/MANIFEST.json"]:
		hashes[source] = FileAccess.get_file_as_string(source).replace("\r\n","\n").sha256_text()
	var report := {"engine":Engine.get_version_info().string,"driver":RenderingServer.get_video_adapter_name(),"capture_kind":"actual desktop rendering; controlled traversal/pose inspection explicitly marked; actual combat phase captures separately identified",
		"source_hashes":hashes,"source_hash_format":"UTF-8 normalized LF","captures":_records,"human_acceptance":"PENDING","runtime_asset_promotion":false,
		"framing":"review-only y-154 and horizontal0..2560; shipping camera unchanged","background_wrap":"alternating mirrored panels, exact matching edge texels; periodic reflection is visible by design"}
	FileAccess.open(_output.path_join("RENDER_REPORT.json"),FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RQ_FOREST_POLISH_RENDER_OK captures=",_records.size()," driver=",RenderingServer.get_video_adapter_name())
	quit(0)
