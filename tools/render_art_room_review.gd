extends SceneTree

## Desktop review renderer; no shipping scene/resource assignment.
var _output: String
var _records: Array = []
var _forest := false
var _enemy: Node

func _init() -> void:
	call_deferred("_run")

func _capture(name: String) -> void:
	for _i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	if image == null or image.is_empty() or image.save_png(_output.path_join(name + ".png")) != OK:
		push_error("Review capture failed: " + name)
		quit(1)
		return
	var phase := "none"
	var clip := "none"
	if is_instance_valid(_enemy):
		var attack = _enemy._attack
		if is_instance_valid(attack):
			phase = String(attack.phase)
		clip = String(_enemy.get_node("SpritePresenter/EnemySprite").animation)
	_records.append({"file":name+".png","size":[image.get_width(),image.get_height()],
		"sha256":FileAccess.get_sha256(_output.path_join(name+".png")),"enemy_phase":phase,"enemy_clip":clip,
		"player_state":String(current_scene.player.current_animation_name()),
		"camera_local_y":current_scene.player.get_node("Camera2D").position.y})

func _run() -> void:
	if DisplayServer.get_name() == "headless":
		push_error("Review capture requires a rendering driver; headless tests are not screenshots")
		quit(1)
		return
	_forest = OS.get_cmdline_user_args().has("--forest-proof")
	_output = ProjectSettings.globalize_path("res://../assets/production_drafts/2026-10-22/"+("forest-room-review/" if _forest else "room-review/"))
	DirAccess.make_dir_recursive_absolute(_output)
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_render_review.json","user://rq_render_review.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("SettingsManager").reload_from_save()
	root.get_node("RunManager").start_run(424242)
	var scene: PackedScene = load("res://scenes/world/RunPrototypeRoom.tscn")
	var room := scene.instantiate()
	root.add_child(room)
	current_scene = room
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(false)
	var player: CharacterBody2D = room.player
	player.position = Vector2(640,614)
	# Diagnostic framing stays within the single room horizontally. These
	# review-only bounds are not an acceptance claim for production camera wrap.
	player.get_node("Camera2D").limit_left = 0
	player.get_node("Camera2D").limit_right = 1280
	# Extend only the diagnostic floor fill below the camera. The real collider
	# and top640 stay unchanged; production ground pixels come in Forest proof.
	room.get_node("Ground/GroundVisual").polygon = PackedVector2Array([-Vector2(700,40),Vector2(700,-40),Vector2(700,500),Vector2(-700,500)])
	var art: Script = load("res://tests/art_review_fixtures.gd")
	if not art.assign(player,room.portal):
		push_error("Could not assign review art")
		quit(1)
		return
	if _forest:
		var fixture: Script = load("res://tests/forest_review_fixture.gd")
		_enemy = fixture.build(room)
		_enemy.set_physics_process(false)
	room.status_label.text = "PROVA VISUAL • sala técnica • artes em revisão"
	var sprite: AnimatedSprite2D = player.get_node("Visual/ProductionSprite")
	for _i in range(20):
		await physics_frame
	player.set_physics_process(false)
	player._update_state()
	player.get_node("Camera2D").reset_smoothing()
	sprite.pause()
	await _capture("room_idle_1280x720")
	root.size = Vector2i(640,360)
	await _capture("room_idle_640x360")
	root.size = Vector2i(1280,720)
	if _forest:
		# Separate framing proposal: retain the baseline captures above. It gives
		# more forest/less underground and keeps feet above touch controls. Only
		# this diagnostic camera changes; shipping camera configuration is untouched.
		player.get_node("Camera2D").position.y = -154.0
		player.get_node("Camera2D").reset_smoothing()
		await _capture("framing_proposal_1280x720")
		root.size = Vector2i(640,360)
		await _capture("framing_proposal_640x360")
		root.size = Vector2i(1280,720)
		_enemy.position = Vector2(685,611)
		_enemy._physics_process(0.0)
		await process_frame
		await process_frame
		paused = true
		await _capture("chaser_tell_1280x720")
		paused = false
		await create_timer(0.27).timeout
		paused = true
		await _capture("chaser_active_1280x720")
		paused = false
		if is_instance_valid(_enemy._attack):
			_enemy._attack.cancel()
		await create_timer(0.25).timeout
	player.respawn()
	player.position = Vector2(1080,614)
	player.get_node("Camera2D").reset_smoothing()
	player.begin_portal_entry(0.36)
	room.portal.start_entry_presentation()
	await create_timer(0.18).timeout
	await _capture("room_portal_mid_1280x720")
	# Render death without room transition so the resting drop can be inspected.
	player.get_node("Health").died.disconnect(room._on_player_died)
	player.get_node("Health").take_damage(1000,true)
	await create_timer(0.4).timeout
	await _capture("room_death_drop_1280x720")
	var source_hashes := {}
	for path in ["res://scripts/player/player_sprite_presenter.gd","res://scripts/portals/portal.gd","res://scripts/enemies/enemy_sprite_presenter.gd","res://tests/art_review_fixtures.gd","res://tests/forest_review_fixture.gd","res://../tools/render_art_room_review.gd","res://../assets/production_drafts/2026-10-22/forest-chaser-proof/MANIFEST.json"]:
		source_hashes[path] = FileAccess.get_file_as_string(path).replace("\r\n","\n").sha256_text()
	var report := {"engine":Engine.get_version_info().string,"driver":RenderingServer.get_video_adapter_name(),
		"capture_kind":"actual desktop Godot rendering; diagnostic state holds, review-only horizontal camera limits0..1280; not physical/human/final acceptance", "forest":_forest,
		"source_hash_format":"UTF-8 text normalized to LF for reproducible Windows/Linux comparison",
		"source_hashes":source_hashes,"captures":_records,"human_acceptance":"PENDING","runtime_asset_promotion":false}
	var report_file := FileAccess.open(_output.path_join("RENDER_REPORT.json"),FileAccess.WRITE)
	report_file.store_string(JSON.stringify(report,"\t"))
	print("RQ_ART_ROOM_RENDER_OK output=",_output," driver=",RenderingServer.get_video_adapter_name())
	quit(0)
