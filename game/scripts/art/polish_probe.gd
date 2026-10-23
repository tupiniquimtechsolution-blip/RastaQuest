extends SceneTree

var room: Node
var player: CharacterBody2D
var combat: Node
var visual: Node
var sprite: AnimatedSprite2D
var capture := false
var captures: Array = []
var failures: Array[String] = []
var output := "res://../assets/production_drafts/2026-10-23/polish-v04/game-review/"

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> void:
	if not ok:
		failures.append(message)
		push_error("POLISH: "+message)

func frames(count := 2) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func snapshot(name: String) -> void:
	if not capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	for reduced in [false,true]:
		var result := image.duplicate()
		if reduced:
			result.resize(640,360,Image.INTERPOLATE_NEAREST)
		var file := name+("_640x360.png" if reduced else "_1280x720.png")
		result.save_png(output+file)
		captures.append({"file":file,"size":[result.get_width(),result.get_height()],"sha256":FileAccess.get_sha256(output+file)})

func _run() -> void:
	capture = "--capture-polish" in OS.get_cmdline_user_args()
	if capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://polish-v04.json","user://polish-v04.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("SettingsManager").reload_from_save()
	root.get_node("RunManager").start_run(424242)
	room = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	await frames()
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames(20)
	player = room.player
	combat = player.combat
	visual = player.get_node("Visual")
	sprite = visual._sprite
	player.set_physics_process(false)
	combat.set_process(false)
	var ephemeral := Node.new()
	room.add_child(ephemeral)
	ephemeral.free()
	await process_frame
	await test_timing()
	await test_lifecycle()
	await test_stride()
	await test_vitals()
	await test_returned_art()
	room._clear_enemies()
	await frames()
	if capture:
		var hashes := {}
		for file in ["res://project.godot","res://scripts/art/polish_probe.gd","res://scripts/art/visual_catalog.gd","res://scripts/player/player_combat.gd","res://scripts/player/player_sprite_presenter.gd","res://scripts/player/player_controller.gd","res://scripts/ui/touch_controls.gd","res://scripts/ui/player_vitals.gd","res://scripts/combat/reflected_projectile.gd","res://scripts/roguelike/run_room_controller.gd","res://localization/strings.csv","res://visual_review/catalog.json"]:
			hashes[file] = FileAccess.get_file_as_string(file).replace("\r\n","\n").sha256_text()
		FileAccess.open(output+"RENDER_REPORT.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":captures,"source_hashes":hashes,"failures":failures,"commercial_approved":false,"physical_acceptance":"PENDING","engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name()},"\t"))
	print("RQ_POLISH_OK" if failures.is_empty() else "RQ_POLISH_FAILED")
	quit(0 if failures.is_empty() else 1)

func test_timing() -> void:
	var run: Node = root.get_node("RunManager")
	for fast in [false,true]:
		if fast:
			run.apply_upgrade(load("res://data/upgrades/quick_hands.tres"))
			room._apply_run_modifiers()
		combat.reset_for_respawn()
		check(combat.try_attack(),"attack start failed")
		var total := 0.26 if fast else 0.30
		combat._process(total*.4)
		check(combat.phase==&"active" and combat.hitbox._active,"upgrade desynchronized active window")
		check(absf(combat.presentation_fraction()-.4)<.001 and sprite.frame==4,"render pose drifted from authoritative attack time")
		await snapshot("fast_attack" if fast else "normal_attack")
		combat._process(total*.61)
		check(combat.phase==&"idle" and not combat.hitbox._active,"complete attack did not scale with quick-hands upgrade")
	combat.attack_cooldown = .34
	combat.reset_for_respawn()
	combat.try_attack()
	combat._process(.301)
	combat.request_attack()
	check(combat._input_buffer>0 and combat.phase==&"idle","press in short idle cooldown was lost")
	combat._process(.04)
	check(combat.current_attack_animation()!=&"","idle cooldown buffer did not start next attack")
	combat.reset_for_respawn()
	room._apply_run_modifiers()

func test_lifecycle() -> void:
	var controls: Node = room.get_node("TouchControls")
	var pause: Node = room.get_node("PauseOverlay")
	for event in ["pause","resize","focus"]:
		combat.reset_for_respawn()
		combat.try_attack()
		combat._process(.06)
		combat.request_attack()
		player._jump_buffer_remaining = .12
		if event=="pause":
			pause._set_paused(true)
		elif event=="resize":
			controls._on_resize()
		else:
			controls._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
		check(combat._input_buffer==0 and player._jump_buffer_remaining==0 and not combat.hitbox._active and combat.current_attack_animation()==&"","stale command/active hitbox survived "+event)
		if event=="pause":
			await snapshot("pause_clean_inputs")
			pause._set_paused(false)
		combat._process(.5)
		check(combat.current_attack_animation()==&"","attack restarted after "+event)

func test_stride() -> void:
	player.velocity.x = 180
	player._update_state()
	# Explicit state calls are presentation fixtures, not new authored art.
	visual._show_state(&"run")
	sprite.set_frame_and_progress(4,.6)
	visual._show_state(&"idle")
	visual._process(.03)
	visual._show_state(&"run")
	check(sprite.frame==4 and absf(sprite.frame_progress-.6)<.001,"brief idle reset run stride")
	sprite.pause()
	await snapshot("stride_continuity")
	visual._show_state(&"idle")
	player.velocity = Vector2.ZERO
	player._update_state()

func test_vitals() -> void:
	var vitals: Control = room._life
	player.health.health = 1.5
	player.health.health_changed.emit()
	check(vitals.bar.value==1.5 and vitals.bar.max_value==5 and not vitals.restored.visible,"fractional/low health HUD mismatch")
	await snapshot("fractional_health")
	player.health._invulnerability_remaining = 0
	player.health.take_damage(.5,true)
	check(vitals.bar.value==1.0 and vitals._notice_remaining==0,"damage falsely displayed a heal")
	var hp_before: float = player.health.health
	var cue := load("res://data/upgrades/restoration.tres")
	room._pending_choices = [cue]
	room._on_upgrade_selected(0)
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames()
	check(hp_before==1 and player.health.health==5 and vitals.bar.value==5 and vitals._notice_remaining>0 and vitals.restored.text=="Vida restaurada","restoration presentation failed")
	var rewards := get_nodes_in_group("review_effect").filter(func(fx):return fx.kind=="reward")
	check(rewards.size()==1,"healing VFX missing or duplicated")
	await snapshot("restoration_feedback")
	root.get_node("SettingsManager").set_value(&"locale","es")
	check(vitals.label.text.contains("Vida") and vitals.restored.text=="Vida restaurada","health locale refresh failed")
	root.get_node("SettingsManager").set_value(&"locale","pt_BR")
	await frames(85)
	check(vitals._notice_remaining==0 and not vitals.restored.visible and get_nodes_in_group("review_effect").is_empty(),"healing feedback exceeded bounded lifetime")
	player.position = Vector2(400,614)
	player.set_physics_process(false)
	combat.set_process(false)

func test_returned_art() -> void:
	var enemy: CharacterBody2D = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
	enemy.data = load("res://data/enemies/ranged.tres").duplicate()
	enemy.position = Vector2(680,611)
	room.get_node("Enemies").add_child(enemy)
	enemy.set_physics_process(false)
	var bolt := preload("res://scripts/combat/reflected_projectile.gd").new()
	bolt.target = enemy
	bolt.defender = player
	room.add_child(bolt)
	bolt.position = Vector2(430,610)
	bolt.set_physics_process(false)
	# Four samples form the bounded presentation trail; no new damage/extent.
	for _i in range(4):
		bolt._physics_process(.016)
	check(bolt._trail.size()<=4 and bolt._shape.radius==9 and bolt.speed==600,"returned shot geometry or trail cap changed")
	check(root.get_node("ArtCatalog").effect_frame("hostile_projectile",0,.24)!=null,"returned shot texture unavailable")
	await snapshot("returned_native_art")
	root.get_node("SettingsManager").set_value(&"reduced_flashes",true)
	bolt._physics_process(.016)
	check(bolt._trail.is_empty(),"reduced effects retained motion trail")
	await snapshot("reduced_effects")
	bolt.queue_free()
	enemy.queue_free()
	root.get_node("SettingsManager").set_value(&"reduced_flashes",false)
