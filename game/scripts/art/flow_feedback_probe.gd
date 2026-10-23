extends SceneTree

const Hostile = preload("res://scripts/combat/hostile_attack.gd")
const Enemy = preload("res://scenes/enemies/EnemyBase.tscn")
var room: Node
var player: CharacterBody2D
var controls: Node
var guard: Node
var run: Node
var capture := false
var captures: Array = []
var output := "res://../assets/production_drafts/2026-10-23/flow-v03/game-review/"
var failures: Array[String] = []

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> bool:
	if not ok:
		failures.append(message)
		push_error("FLOW: "+message)
	return ok

func frames(count := 2) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func snapshot(label: String) -> void:
	if not capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var source := root.get_texture().get_image()
	for reduced in [false,true]:
		var image := source.duplicate()
		if reduced:
			image.resize(640,360,Image.INTERPOLATE_NEAREST)
		var name := label+("_640x360.png" if reduced else "_1280x720.png")
		image.save_png(output+name)
		captures.append({"file":name,"size":[image.get_width(),image.get_height()],"sha256":FileAccess.get_sha256(output+name)})

func enemy_at(at: Vector2, behavior := "chaser") -> CharacterBody2D:
	var enemy := Enemy.instantiate()
	enemy.data = load("res://data/enemies/"+behavior+".tres").duplicate()
	enemy.position = at
	enemy.target_path = NodePath("../../Player")
	room.get_node("Enemies").add_child(enemy)
	enemy.set_physics_process(false)
	return enemy

func clear_actor(enemy: Node) -> void:
	enemy.queue_free()
	for bolt in get_nodes_in_group("reflected_projectile"):
		bolt.queue_free()
	await frames()

func _run() -> void:
	capture = "--capture-flow" in OS.get_cmdline_user_args()
	if capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://flow-feedback.json","user://flow-feedback.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("SettingsManager").reload_from_save()
	run = root.get_node("RunManager")
	run.start_run(424242)
	room = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	await frames()
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames()
	player = room.player
	controls = room.get_node("TouchControls")
	guard = player.get_node("PlayerGuard")
	check(is_equal_approx(guard.perfect_window,.28),"base parry window must be 280ms")
	check(tr("upgrade_restoration_title")=="Restauração" and tr("health_status").contains("Vida"),"new Portuguese strings missing")
	await test_jump()
	await test_defense()
	await test_reflection()
	await test_platforms_contact()
	await test_combo()
	await test_healing()
	controls.release_held_actions()
	if capture:
		var hashes := {}
		for file in ["res://project.godot","res://scripts/player/player_controller.gd","res://scripts/player/player_combat.gd","res://scripts/player/player_guard.gd","res://scripts/player/player_sprite_presenter.gd","res://scripts/combat/hostile_attack.gd","res://scripts/combat/reflected_projectile.gd","res://scripts/combat/health_component.gd","res://scripts/roguelike/run_room_controller.gd","res://scripts/roguelike/world_layout.gd","res://scripts/ui/touch_pad.gd","res://scripts/enemies/enemy_base.gd","res://scripts/enemies/enemy_brain.gd","res://scripts/art/flow_feedback_probe.gd","res://visual_review/catalog.json"]:
			hashes[file] = FileAccess.get_file_as_string(file).replace("\r\n","\n").sha256_text()
		var report := {"captures":captures,"source_hashes":hashes,"failures":failures,"commercial_approved":false,"new_build_physical_acceptance":"PENDING","engine":Engine.get_version_info().string,"renderer":RenderingServer.get_video_adapter_name(),"hash_format":"UTF8 normalized LF"}
		FileAccess.open(output+"RENDER_REPORT.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RQ_FLOW_FEEDBACK_OK" if failures.is_empty() else "RQ_FLOW_FEEDBACK_FAILED")
	quit(0 if failures.is_empty() else 1)

func test_jump() -> void:
	player.respawn()
	await frames(20)
	Input.action_press("jump")
	await frames(2)
	check(player.velocity.y<0 and player._jumps_used==1,"first jump input")
	await frames(5)
	check(player._jumps_used==1,"held jump spent second jump")
	Input.action_release("jump")
	await frames()
	Input.action_press("jump")
	await frames()
	check(player.velocity.y< -350 and player._jumps_used==2,"second jump did not reset ascent")
	await snapshot("double_jump")
	Input.action_release("jump")
	await frames()
	Input.action_press("jump")
	await frames()
	check(player._jumps_used==2,"third jump permitted")
	Input.action_release("jump")
	await frames(90)
	check(player.is_on_floor() and player._jumps_used==0,"landing did not rearm jumps")
	var stick: Control = controls.joystick
	stick.finger = 91
	var center: Vector2 = stick.global_position+stick.size*.5
	stick._move(center+Vector2(0,-60))
	await frames(2)
	check(player._jumps_used==1,"upward joystick did not jump")
	stick._move(center+Vector2(0,-60))
	await frames(3)
	check(player._jumps_used==1,"held upward stick auto-double-jumped")
	stick._move(center)
	await frames()
	stick._move(center+Vector2(0,-60))
	await frames()
	check(player._jumps_used==2,"neutral/rearm joystick second jump failed")
	Input.action_press("jump")
	stick.release()
	check(Input.is_action_pressed("jump") and not Input.is_action_pressed("jump_stick"),"stick release stole jump button")
	controls.release_held_actions()
	player.respawn()
	await frames(30)

func test_defense() -> void:
	player.set_physics_process(false)
	player.position = Vector2(400,614)
	var enemy := enemy_at(Vector2(450,611))
	guard.set_process(false)
	for side in [1.0,-1.0]:
		enemy.position.x = player.position.x+side*50
		guard.guarding = true
		guard._age = .26
		guard._spent = false
		guard._cooldown = 0
		var hp: float = enemy.health.health
		var response: Dictionary = guard.resolve_hit({"amount":1.0,"damage_type":&"chaser","source":enemy.get_instance_id()})
		check(response.parried and is_equal_approx(enemy.health.health,hp-.5) and enemy._parry_push*side>0,"late-window 360 counter / half damage / away push")
		response = guard.resolve_hit({"amount":1.0,"damage_type":&"chaser","source":enemy.get_instance_id()})
		check(not response.parried and response.amount==.5,"two perfect counters from one press")
	guard._spent = false
	guard._cooldown = 0
	guard._age = .4
	check(guard.resolve_hit({"amount":1.0,"damage_type":&"chaser","source":enemy.get_instance_id()}).amount==.5,"outside perfect window must mitigate")
	for kind in [&"controller",&"exploder",&"contact"]:
		check(guard.resolve_hit({"amount":2.0,"damage_type":kind,"source":enemy.get_instance_id()}).amount==1.0,"held defense failed area/contact mitigation")
	guard.queue_redraw()
	await snapshot("circular_defense")
	guard.reset()
	guard.set_process(true)
	await clear_actor(enemy)

func test_reflection() -> void:
	player.position = Vector2(400,614)
	var enemy := enemy_at(Vector2(620,611),"ranged")
	enemy.health.max_health = 10
	enemy.health.reset_health()
	Input.action_press("guard")
	await frames(30) # Outside perfect window: held defense still reflects shots.
	var health_before: float = player.health.health
	var attack := Hostile.new()
	enemy.add_child(attack)
	check(attack.begin(enemy,player,"ranged",.05),"ranged attack could not begin")
	var reflected := false
	for _i in range(70):
		await frames(1)
		if not reflected and not get_nodes_in_group("reflected_projectile").is_empty():
			reflected = true
			await snapshot("returned_projectile")
		if enemy.health.health<10:
			break
	check(reflected and enemy.health.health==9 and player.health.health==health_before,"real held defense did not return projectile exactly once")
	await frames(6)
	check(enemy.health.health==9,"returned projectile hit shooter repeatedly")
	# Every projectile in a volley can independently reflect.
	var volley := Hostile.new()
	enemy.add_child(volley)
	volley.begin(enemy,player,"chain_burst",.05)
	volley.set_physics_process(false)
	volley.phase = &"active"
	for i in range(3):
		check(volley.reflect_projectile(i,player),"volley slot failed reflection")
		check(not volley.reflect_projectile(i,player),"volley slot reflected twice")
	check(get_nodes_in_group("reflected_projectile").size()==3,"volley did not create three bounded return shots")
	volley.cancel()
	await clear_actor(enemy)
	controls.release_held_actions()
	# Wall interception and lifetime: no instant or through-wall damage.
	enemy = enemy_at(Vector2(620,611),"ranged")
	var wall := StaticBody2D.new()
	wall.position = Vector2(510,610)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(20,140)
	collision.shape = rectangle
	wall.add_child(collision)
	room.add_child(wall)
	await frames()
	var bolt := preload("res://scripts/combat/reflected_projectile.gd").new()
	bolt.target = enemy
	bolt.defender = player
	room.add_child(bolt)
	bolt.position = Vector2(420,610)
	var hp: float = enemy.health.health
	await frames(25)
	check(not is_instance_valid(bolt) and enemy.health.health==hp,"returned shot passed through wall")
	wall.queue_free()
	await clear_actor(enemy)
	player.respawn()
	player.set_physics_process(true)
	await frames(20)

func test_platforms_contact() -> void:
	for rect in room.platform_rects:
		check(640.0-rect.end.y>=96.0,"low platform blocks enemy passage")
	var enemy := enemy_at(Vector2(610,611))
	enemy._engaged = true
	enemy._attack_cooldown_remaining = 100
	player.position = Vector2(1120,614)
	player.set_physics_process(false)
	enemy.set_physics_process(true)
	for _i in range(110):
		await frames(1)
		if enemy.position.x>840:
			break
	check(enemy.position.x>800 and enemy.is_on_floor(),"enemy could not pass below first platform")
	player.position.x = enemy.position.x+1800
	await frames(2)
	check(enemy._engaged,"engagement reset at screen edge")
	enemy.set_physics_process(false)
	player.position = enemy.position+Vector2(0,-75)
	player.velocity = Vector2.ZERO
	player.health.restore_full()
	player.set_physics_process(true)
	await frames(25)
	check(player.position.y>enemy.position.y-55 and not (player.is_on_floor() and player.position.y<600),"enemy became standable floor")
	check(player.health.health<5 and absf(player._contact_push)>0,"overlap failed contact damage and separation")
	await snapshot("raised_platforms_contact")
	await clear_actor(enemy)
	player.respawn()
	await frames(20)

func test_combo() -> void:
	player.health.restore_full()
	player._hurt_remaining = 0
	player.combat.reset_for_respawn()
	player.combat.set_process(false)
	var names: Array = []
	for _i in range(3):
		check(player.combat.try_attack(),"ground combo failed to start")
		names.append(player.combat.current_attack_animation())
		player.combat._process(.051)
		check(player.combat.hitbox._active,"combo active did not open hitbox")
		player.get_node("Visual")._sprite.frame = 3
		await snapshot("combo_"+str(_i+1))
		player.combat._process(.161)
		check(not player.combat.hitbox._active,"recovery kept damage active")
		player.combat.request_attack()
		check(player.combat._input_buffer>0.0,"recovery command not buffered")
		player.combat._process(.1)
		player.combat._process(.05)
		# Buffered command either starts next attack or waits for cooldown.
		check(player.combat.current_attack_animation()!=&"","buffered command lost")
		player.combat.cancel_attack()
		player.combat._cooldown_remaining = 0
		player.combat._combo_grace = .65
		player.combat.combo_index = _i
	check(names==[&"attack_axe",&"attack_axe_2",&"attack_axe_3"],"three distinct combo clips missing: "+str(names))
	player.combat.cancel_attack()
	check(player.combat._input_buffer==0 and not player.combat.hitbox._active,"cancel retained combo input/hitbox")
	player.combat.set_process(true)
	var sprite: AnimatedSprite2D = player.get_node("Visual")._sprite
	check(sprite.sprite_frames.get_frame_count(&"run")==8 and sprite.sprite_frames.get_frame_count(&"attack_axe_2")==8,"new native motion keys not installed")

func test_healing() -> void:
	player.combat.reset_for_respawn()
	player.health.health = 1.5
	room._apply_run_modifiers()
	check(player.health.health==1.5,"normal modifiers silently restored health")
	player.respawn(false)
	check(player.health.health==1.5,"room respawn silently restored health")
	var choices: Array = run.sample_upgrade_choices(3,true)
	var cure: UpgradeData
	for upgrade in choices:
		if upgrade.id==&"restoration":
			cure = upgrade
	check(cure!=null and choices.size()==3,"injured player missing guaranteed portal cure")
	for upgrade in run.sample_upgrade_choices(3,false):
		check(upgrade.id!=&"restoration","full-health player offered useless cure")
	var before_ids: int = run.state.applied_upgrade_ids.size()
	check(run.apply_upgrade(cure) and run.apply_upgrade(cure),"restoration not repeatable")
	check(run.state.applied_upgrade_ids.size()==before_ids and not run.state.modifiers.has(&"heal"),"heal stacked permanent modifier")
	room._pending_choices = [cure]
	room._on_upgrade_selected(0)
	check(player.health.health==5 and player.health.max_health==5,"portal cure failed or increased max health")
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames()
	player.health.health = 2.0
	var normal: UpgradeData = load("res://data/upgrades/raw_power.tres")
	room._pending_choices = [normal]
	room._on_upgrade_selected(0)
	check(player.health.health==2.0,"ordinary portal upgrade still auto-heals")
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames()
	var repeat_choices: Array = run.sample_upgrade_choices(3,true)
	var has_cure := false
	for upgrade in repeat_choices:
		has_cure = has_cure or upgrade.id==&"restoration"
	check(has_cure,"next portal lost repeatable cure")
	player.health.health_changed.emit()
	room.portal.set_locked(false)
	player.position = room.portal.position
	await create_timer(.95).timeout
	check(room.reward_panel.visible and room._pending_choices.any(func(u): return u.id==&"restoration"),"actual portal transition failed to offer cure")
	await snapshot("restoration_health_hud")
