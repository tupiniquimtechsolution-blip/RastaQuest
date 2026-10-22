extends SceneTree

## Real scene and actual draft pixels, not shipping or visual acceptance evidence.
var _ended_count := 0

func _init() -> void:
	call_deferred("_run")

func _study_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	var prefix := ProjectSettings.globalize_path("res://../assets/production_drafts/2026-10-22/")
	var clips := {
		&"idle": ["axe-idle-2x/player_idle_%02d.png", [200, 200, 200, 200]],
		&"run": ["run-2x/player_run_%02d.png", [60, 60, 60, 60, 60, 60]],
		&"jump": ["airborne-2x/jump_combined_%02d.png", [100]],
		&"fall": ["airborne-2x/fall_combined_%02d.png", [100]],
		&"attack_axe": ["combat-reaction-2x/attack_axe_%02d_combined.png", [40, 40, 40, 40]],
		&"attack_axe_air": ["combat-reaction-2x/attack_axe_air_%02d_combined.png", [50, 55, 55]],
		&"hurt": ["combat-reaction-2x/hurt_%02d_combined.png", [90, 90]],
		&"death": ["combat-reaction-2x/death_%02d_combined.png", [120, 140, 160, 180]],
	}
	for clip in clips:
		frames.add_animation(clip)
		frames.set_animation_loop(clip, clip in [&"idle", &"run"])
		frames.set_animation_speed(clip, 1000.0)
		for index in range(clips[clip][1].size()):
			var image := Image.new()
			if image.load(prefix + (clips[clip][0] % (index + 1))) != OK:
				return null
			frames.add_frame(clip, ImageTexture.create_from_image(image), clips[clip][1][index])
	return frames

func _room(scene: PackedScene) -> Node2D:
	var room := scene.instantiate() as Node2D
	root.add_child(room)
	current_scene = room
	room._clear_enemies()
	return room

func _run() -> void:
	var room_scene: PackedScene = load("res://scenes/world/RunPrototypeRoom.tscn")
	var save: Node = root.get_node("SaveManager")
	var run: Node = root.get_node("RunManager")
	save.configure_paths("user://rq_death_test.json", "user://rq_death_test.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete", true)
	run.run_ended.connect(func(): _ended_count += 1)
	run.start_run(424242)
	run.state.depth = 3
	var room := _room(room_scene)
	var player: CharacterBody2D = room.get_node("Player")
	var visual: Node2D = player.get_node("Visual")
	var combat: Node = player.get_node("PlayerCombat")
	var health: Node = player.get_node("Health")
	var hitbox: Area2D = player.get_node("AttackHitbox")
	var frames := _study_frames()
	if frames == null or not visual.apply_frames(frames):
		_fail("actual eight-clip prototype pack could not be assigned in test scene")
		return
	var sprite: AnimatedSprite2D = visual.get_node("ProductionSprite")
	if not is_equal_approx(visual.death_presentation_seconds(), 0.6):
		_fail("death lifetime must use actual variable frame durations")
		return
	var looping := frames.duplicate(true) as SpriteFrames
	looping.set_animation_loop(&"death", true)
	if visual.apply_frames(looping) or sprite.sprite_frames != frames:
		_fail("looping death must not replace the current complete pack")
		return
	var frozen := frames.duplicate(true) as SpriteFrames
	frozen.set_animation_speed(&"death", 0.0)
	if visual.apply_frames(frozen):
		_fail("zero-speed animation must be rejected")
		return
	var long_death := frames.duplicate(true) as SpriteFrames
	long_death.set_animation_speed(&"death", 1.0)
	visual.apply_frames(long_death)
	if visual.death_presentation_seconds() != 1.5:
		_fail("death lifetime must be bounded independently of art completion")
		return
	visual.apply_frames(frames)
	for _i in range(12):
		await physics_frame
	if not player.is_on_floor() or not combat.try_attack() or sprite.animation != &"attack_axe":
		_fail("actual grounded attack did not reach the study sprite")
		return
	health.take_damage(1, true)
	if sprite.animation != &"hurt" or hitbox._active or combat.try_attack():
		_fail("damage must immediately cancel attack and reject new attacks during hurt")
		return
	await create_timer(0.2).timeout
	player.respawn()
	if hitbox._active or combat.current_attack_animation() != &"":
		_fail("respawn retained an old attack")
		return
	if not combat.try_attack():
		_fail("respawn retained the previous cooldown")
		return
	player.respawn()
	if hitbox._active or combat.current_attack_animation() != &"":
		_fail("respawn must also cancel an attack still in progress")
		return
	# Real input and floor separation, rather than emitting animation names.
	for _i in range(8):
		await physics_frame
	Input.action_press("move_right")
	for _i in range(5):
		await physics_frame
	Input.action_release("move_right")
	if sprite.animation != &"run" or sprite.scale != Vector2(0.5, 0.5):
		_fail("run input or source density failed")
		return
	Input.action_press("jump")
	for _i in range(3):
		await physics_frame
	Input.action_release("jump")
	if sprite.animation != &"jump":
		_fail("jump input did not reach the study sprite")
		return
	player.velocity.y = 100.0
	player._update_state()
	if sprite.animation != &"fall" or not combat.try_attack() or sprite.animation != &"attack_axe_air":
		_fail("fall/air attack failed through real controller states")
		return
	player.set_physics_process(false)
	# Fatal damage inside a real Area2D query flush catches unsafe monitoring
	# toggles on player hitbox and portal, which direct signal tests miss.
	var fatal := Area2D.new()
	fatal.set_script(load("res://scripts/combat/hitbox.gd"))
	fatal.collision_layer = 0
	fatal.collision_mask = 2
	fatal.position = player.position
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(60, 80)
	shape.shape = rectangle
	fatal.add_child(shape)
	room.add_child(fatal)
	health.invulnerability_seconds = 0.0
	health._invulnerability_remaining = 0.0
	fatal.begin_attack(99, 1000, &"test")
	for _i in range(4):
		await physics_frame
		await process_frame
	if not health.dead or sprite.animation != &"death" or hitbox._active or combat.try_attack():
		_fail("fatal contact did not cancel damage or select death")
		return
	var dummy_scene: PackedScene = load("res://scenes/enemies/TrainingDummy.tscn")
	var dummy := dummy_scene.instantiate()
	dummy.position = Vector2(2000, 0)
	room.add_child(dummy)
	var target_health: Node = dummy.get_node("Health")
	var before: int = target_health.health
	hitbox._on_area_entered(dummy.get_node("Hurtbox"))
	if target_health.health != before:
		_fail("late overlap after player death still damaged a target")
		return
	room._on_player_died()
	room._on_portal_entered()
	room._on_upgrade_selected(0)
	if _ended_count != 1 or save.meta_shards() != 3 or not room.portal.locked or room.reward_panel.visible:
		_fail("death paid rewards twice or allowed encounter progression")
		return
	await create_timer(0.2).timeout
	if current_scene != room:
		_fail("scene was removed before death presentation completed")
		return
	await create_timer(0.5).timeout
	if current_scene == room or current_scene.scene_file_path != "res://scenes/hub/Hub.tscn" or _ended_count != 1:
		_fail("bounded death presentation failed to return to hub exactly once")
		return
	# Default shipping scene has no assigned art and keeps its immediate fallback.
	current_scene.queue_free()
	await process_frame
	run.start_run(424242)
	room = _room(room_scene)
	player = room.get_node("Player")
	player.set_physics_process(false)
	if player.get_node("Visual").death_presentation_seconds() != 0.0:
		_fail("unassigned art must keep the immediate fallback")
		return
	player.get_node("Health").take_damage(1000, true)
	for _i in range(4):
		await process_frame
	if current_scene == room or _ended_count != 2 or save.meta_shards() != 4:
		_fail("no-art fallback or one-time reward changed")
		return
	print("RQ_PLAYER_DEATH_PRESENTATION_OK actual_draft_clips=8 lifetime=0.6 fallback=immediate cancellation=pass rewards=once assets=not-shipping")
	quit(0)

func _fail(message: String) -> void:
	Input.action_release("move_right")
	Input.action_release("jump")
	push_error(message)
	quit(1)
