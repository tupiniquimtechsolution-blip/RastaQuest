extends SceneTree

const Hostile = preload("res://scripts/combat/hostile_attack.gd")
const Layout = preload("res://scripts/roguelike/world_layout.gd")
var _captures: Array = []
var _capture := false
var _output := "res://../assets/production_drafts/2026-10-23/a13-feedback-v02/game-review/"

func _init() -> void:
	call_deferred("_run")

func check(ok: bool, message: String) -> bool:
	if not ok:
		push_error("A13: "+message)
		quit(1)
	return ok

func frames(count := 2) -> void:
	for _i in range(count):
		await physics_frame
		await process_frame

func snapshot(label: String) -> void:
	if not _capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	for reduced in [false,true]:
		var result := image.duplicate()
		if reduced:
			result.resize(640,360,Image.INTERPOLATE_NEAREST)
		var file := label+("_640x360.png" if reduced else "_1280x720.png")
		result.save_png(_output+file)
		_captures.append({"file":file,"sha256":FileAccess.get_sha256(_output+file),"size":[result.get_width(),result.get_height()]})

func touch(pad: Control, index: int, pressed: bool, offset := Vector2.ZERO) -> void:
	var event := InputEventScreenTouch.new()
	event.index = index
	event.pressed = pressed
	event.position = pad.global_position+pad.size*.5+offset
	root.push_input(event,true)

func _run() -> void:
	_capture = "--capture-a13" in OS.get_cmdline_user_args()
	if _capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_output))
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://a13-feedback.json","user://a13-feedback.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	var settings: Node = root.get_node("SettingsManager")
	settings.reload_from_save()
	if not check(settings.get_value(&"locale")=="pt_BR" and tr("upgrade_raw_power_title")=="Força bruta","Portuguese default/upgrades missing: %s / %s / %s" % [settings.get_value(&"locale"),TranslationServer.get_locale(),tr("upgrade_raw_power_title")]):
		return
	if not check(ProjectSettings.get_setting("display/window/handheld/orientation")==4,"sensor landscape missing"):
		return
	var run: Node = root.get_node("RunManager")
	run.start_run(424242)
	var room: Node = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	await frames()
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(true)
	await frames()
	var player: CharacterBody2D = room.player
	var controls: Node = room.get_node("TouchControls")
	# Real ScreenTouch dispatch: three fingers, outside drags, unrelated releases.
	touch(controls.joystick,0,true,Vector2(48,0))
	touch(controls.jump_button,1,true)
	touch(controls.attack_button,2,true)
	if not check(Input.get_action_strength("move_right")>0.1 and Input.is_action_pressed("jump") and Input.is_action_pressed("attack"),"multitouch inputs did not coexist: %s %s %s / fingers %s %s %s / viewport %s" % [Input.get_action_strength("move_right"),Input.is_action_pressed("jump"),Input.is_action_pressed("attack"),controls.joystick.finger,controls.jump_button.finger,controls.attack_button.finger,root.get_visible_rect()]):
		return
	touch(controls.jump_button,1,false)
	if not check(Input.is_action_pressed("move_right") and Input.is_action_pressed("attack") and not Input.is_action_pressed("jump"),"one release stole another finger"):
		return
	controls._on_resize()
	if not check(not Input.is_action_pressed("move_right") and not Input.is_action_pressed("attack") and controls.joystick.finger == -1,"resize left a held action"):
		return
	await frames(25)
	player.combat.reset_for_respawn()
	touch(controls.guard_button,3,true)
	await frames(2)
	if not check(player.get_node("PlayerGuard").guarding and not player.combat.try_attack(),"guard/attack mutual exclusion missing: pressed=%s guard=%s can_raise=%s animation=%s finger=%s" % [Input.is_action_pressed("guard"),player.get_node("PlayerGuard").guarding,player.get_node("PlayerGuard").can_raise(),player.combat.current_attack_animation(),controls.guard_button.finger]):
		return
	controls.release_held_actions()
	player.combat.reset_for_respawn()
	# Check authoritative windup/active/recovery; cancel during every phase.
	player.combat.set_process(false)
	for phase in [&"windup",&"active",&"recovery"]:
		player.combat.reset_for_respawn()
		if not check(player.combat.try_attack() and not player.combat.hitbox._active,"windup applied early damage"):
			return
		if phase != &"windup":
			player.combat._process(.051)
			if not check(player.combat.phase==&"active" and player.combat.hitbox._active,"active damage absent"):
				return
		if phase == &"recovery":
			player.combat._process(.161)
			if not check(player.combat.phase==&"recovery" and not player.combat.hitbox._active,"recovery still damaging"):
				return
		player.combat.cancel_attack()
		if not check(player.combat.phase==&"idle" and not player.combat.hitbox._active,"cancel left live hitbox"):
			return
	player.combat.reset_for_respawn()
	player.combat.set_process(true)
	player.set_physics_process(false)
	player.position = Vector2(220,614)
	var enemy: CharacterBody2D = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
	enemy.data = load("res://data/enemies/chaser.tres").duplicate()
	enemy.position = Vector2(270,611)
	room.get_node("Enemies").add_child(enemy)
	enemy.set_physics_process(false)
	await frames()
	var health: Node = player.get_node("Health")
	var guard: Node = player.get_node("PlayerGuard")
	var hurtbox: Node = player.get_node("Hurtbox")
	var original_health: float = enemy.health.health
	var attack := Hostile.new()
	enemy.add_child(attack)
	attack.begin(enemy,player,"chaser",.2)
	enemy._attack = attack
	touch(controls.guard_button,4,true)
	await frames(1)
	await snapshot("perfect_guard_ready")
	attack._remaining = 0.0
	await frames(2)
	if not check(health.health==5.0 and is_equal_approx(enemy.health.health,original_health-.5) and enemy._parry_push>0 and not is_instance_valid(enemy._attack),"actual melee parry failed half damage/cancellation"):
		return
	await snapshot("perfect_counter")
	var before := enemy.position.x
	enemy._physics_process(.05)
	if not check(enemy.velocity.x>0 and enemy.position.x>before,"parry did not physically push enemy"):
		return
	controls.release_held_actions()
	# Outside window mitigates; back attacks, shots and ground AoE stay dangerous.
	var payload := {"amount":1.0,"damage_type":&"chaser","source":enemy.get_instance_id()}
	guard.guarding = true
	guard._age = .3
	health.reset_health()
	hurtbox.receive_hit(payload)
	if not check(health.health==4.5,"late block truncated fractional damage"):
		return
	player._hurt_remaining = 0.0
	guard.guarding = true
	guard._age = 0.0
	for kind in [&"ranged",&"controller"]:
		payload.damage_type = kind
		if not check(guard.resolve_hit(payload).amount == 1.0,"ranged/area incorrectly parried"):
			return
	payload.damage_type = &"chaser"
	enemy.position.x = 180
	if not check(guard.resolve_hit(payload).amount==1.0,"rear hit incorrectly blocked"):
		return
	enemy.queue_free()
	controls.release_held_actions()
	player.respawn()
	player.set_physics_process(true)
	var upgrades: Array = load("res://scripts/roguelike/upgrade_catalog.gd").load_all()
	for upgrade in upgrades:
		if upgrade.id in [&"guardian_reflex",&"counterweight"]:
			run.apply_upgrade(upgrade)
	room._apply_run_modifiers()
	if not check(is_equal_approx(guard.perfect_window,.175) and guard.push_speed==440.0,"parry upgrades did not affect runtime"):
		return
	# Every real platform shares render bounds with its actual collider.
	var route_results: Array = []
	for biome in [&"forest",&"castle",&"caves"]:
		run.state.biome = biome
		room._start_encounter()
		await frames()
		var roles: Array = []
		for actor in room.get_node("Enemies").get_children():
			if actor is CharacterBody2D:
				roles.append(actor.data.behavior)
		room._clear_enemies()
		room._alive_enemies = 0
		room.portal.set_locked(true)
		await frames()
		for rect in room.platform_rects:
			player.position = Vector2(rect.get_center().x,rect.position.y-100)
			player.velocity = Vector2.ZERO
			await frames(42)
			if not check(player.is_on_floor() and absf(player.position.y+26-rect.position.y)<1.0,String(biome)+" platform/collider mismatch"):
				return
		player.respawn()
		player.position = Vector2(180,614)
		var camera: Camera2D = player.get_node("Camera2D")
		camera.reset_smoothing()
		await frames(3)
		camera.force_update_scroll()
		var initial := camera.get_screen_center_position().x
		Input.action_press("move_right")
		for i in range(1000):
			# The capture window may lose focus; the scripted traversal driver
			# re-engages movement. Focus/resize release is checked independently.
			Input.action_press("move_right")
			Input.action_release("jump")
			if player.is_on_floor() and i%2==0:
				Input.action_press("jump")
			await frames(1)
			if player.position.x >= room.world_width-280:
				break
		Input.action_release("jump")
		Input.action_release("move_right")
		camera.force_update_scroll()
		if not check(player.position.x>=room.world_width-300 and camera.get_screen_center_position().x-initial>1800,String(biome)+" side-scrolling route blocked: x=%s y=%s cam=%s" % [player.position.x,player.position.y,camera.get_screen_center_position().x-initial]):
			return
		route_results.append({"biome":String(biome),"width":room.world_width,"traversed_x":player.position.x,"camera_delta":camera.get_screen_center_position().x-initial,"enemy_roles":roles})
		await snapshot(String(biome)+"_route_end")
		if root.get_node("ArtCatalog").enabled():
			var sprite: AnimatedSprite2D = player.get_node("Visual/ProductionSprite")
			if not check(is_equal_approx(sprite.scale.x,.575) and is_equal_approx(sprite.position.y,-3.9),"15% scale or foot anchor missing"):
				return
	# Real reward and destination transition, then change language without rerolling.
	run.state.biome = &"forest"
	run.state.depth = 0
	room._start_encounter()
	room._clear_enemies()
	room._alive_enemies = 0
	await frames()
	player.respawn()
	room.portal.set_locked(false)
	player.position = room.portal.position
	await create_timer(.95).timeout
	if not check(room.reward_panel.visible and room._pending_choices.size()==3,"actual portal/reward transition failed"):
		return
	var ids: Array = room._pending_choices.map(func(u): return u.id)
	settings.set_value(&"locale","es")
	await frames()
	if not check(ids==room._pending_choices.map(func(u): return u.id) and not room.reward_buttons[0].text.begins_with("upgrade_") and tr("choose_upgrade")=="Elige una mejora","Spanish reward rerolled or untranslated"):
		return
	await snapshot("spanish_rewards")
	room._on_upgrade_selected(0)
	await frames()
	if not check(run.state.biome==&"castle" and room.world_width==4480 and not room.reward_panel.visible,"portal did not change world/composition"):
		return
	settings.set_value(&"locale","pt_BR")
	await snapshot("castle_destination")
	if _capture:
		var hashes := {}
		for file in ["res://scenes/world/RunPrototypeRoom.tscn","res://localization/strings.csv","res://scripts/art/a13_feedback_probe.gd","res://scripts/art/visual_catalog.gd","res://scripts/art/playable_art_layers.gd","res://scripts/combat/health_component.gd","res://scripts/combat/hurtbox.gd","res://scripts/combat/hostile_attack.gd","res://scripts/enemies/enemy_base.gd","res://scripts/player/player_sprite_presenter.gd","res://scripts/core/settings_policy.gd","res://scripts/save/save_manager.gd","res://assets/ui/axe.svg","res://assets/ui/jump.svg","res://assets/ui/shield.svg","res://project.godot","res://scripts/ui/touch_controls.gd","res://scripts/ui/touch_pad.gd","res://scripts/player/player_guard.gd","res://scripts/player/player_combat.gd","res://scripts/roguelike/world_layout.gd","res://scripts/roguelike/run_room_controller.gd","res://visual_review/catalog.json"]:
			hashes[file]=FileAccess.get_file_as_string(file).replace("\r\n","\n").sha256_text()
		FileAccess.open(_output+"RENDER_REPORT.json",FileAccess.WRITE).store_string(JSON.stringify({"captures":_captures,"routes":route_results,"source_hashes":hashes,"hash_format":"UTF8 normalized LF","new_build_physical_acceptance":"PENDING","commercial_approved":false},"\t"))
	room.queue_free()
	await frames()
	print("RQ_A13_FEEDBACK_OK multitouch=pass fractional_parry=pass attack_phases=pass locales=3 routes=3 portal_biome=pass scale=1.15 commercial_approved=false")
	quit(0)
