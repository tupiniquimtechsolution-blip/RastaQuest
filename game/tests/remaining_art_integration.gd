extends SceneTree

const Fixture = preload("res://tests/remaining_art_fixture.gd")
var _trace: Array = []

func _init() -> void:
	call_deferred("_run")

func check(ok: bool,message: String) -> bool:
	if not ok:
		push_error(message)
		quit(1)
	return ok

func room_for(biome: String) -> Node:
	root.get_node("RunManager").start_run(424242)
	var room: Node = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	room._clear_enemies()
	room._alive_enemies = 0
	Fixture.environment(room,biome)
	return room

func exercise(role: String,ratio: float) -> bool:
	var room := room_for("castle" if role in ["ranged","storm_warden"] else "caves")
	var boss := role in ["storm_warden","rift_sovereign"]
	var actor: CharacterBody2D = Fixture.boss(room,role) if boss else Fixture.enemy(room,role)
	actor.set_physics_process(false)
	actor.get_node("Health").health = maxi(1,roundi(actor.get_node("Health").max_health*ratio))
	actor.position = Vector2(880 if role=="ranged" else 720,584 if boss else 611)
	room.player.position = Vector2(640,614)
	var health: Node = room.player.get_node("Health")
	health.max_health = 100
	health.reset_health()
	room.player.set_physics_process(false)
	var presenter: Node = actor.get_node("ArtPresenter" if boss else "RosterPresenter")
	var sprite: AnimatedSprite2D = presenter.get_node("HostileSprite")
	var shape: Vector2 = actor.get_node("CollisionShape2D").shape.size
	if not check(shape==Vector2(78,112) if boss else shape==Vector2(34,58),role+": collision changed"):
		return false
	var seen := {}
	var emitted := [0.0]
	var defeats := [0]
	actor.attack_tell_started.connect(func(_p,t): emitted[0] = t)
	if boss:
		actor.boss_defeated.connect(func(): defeats[0] += 1)
	else:
		actor.enemy_defeated.connect(func(_n): defeats[0] += 1)
	actor.set_physics_process(true)
	var pattern := ""
	var started := Time.get_ticks_msec()
	for _i in range(220):
		await physics_frame
		await process_frame
		if not is_instance_valid(actor):
			break
		var attack = actor._attack
		if is_instance_valid(attack) and attack.phase in [&"tell",&"active"]:
			pattern = attack.kind
			seen[String(attack.phase)] = true
			seen[String(sprite.animation)] = true
		var expected_attack: String = String(Fixture.manifest().actors[role].patterns.get(pattern,["",""])[1])
		if seen.has("active") and seen.has(expected_attack) and health.health<100:
			break
	if not check(seen.has("tell") and seen.has("active") and health.health<100 and pattern!="",role+": actual attack or damage missing"):
		room.queue_free()
		return false
	var pair: Array = Fixture.manifest().actors[role].patterns[pattern]
	if not check(seen.has(String(pair[0])) and seen.has(String(pair[1])),role+": art did not follow actual pattern "+pattern):
		return false
	var expected: float = {"ranged":.45,"charger":.7425,"controller":1.05,"exploder":1.4,"storm_slam":.65,"chain_burst":.4,"rift_slam":.6,"portal_burst":.48,"fracture_storm":.36}.get(pattern,0)
	if not check(absf(emitted[0]-expected)<.001 and absf(presenter._tell-expected)<.001,role+": emitted tell mismatch"):
		return false
	if role in ["ranged","controller"]:
		await create_timer(.20).timeout
		if not check(sprite.animation==&"idle",role+": body release pose incorrectly follows projectile/area lifetime"):
			return false
	if role=="exploder":
		await create_timer(.20).timeout # Exercise its real self-destruction too.
		if not check(actor.get_node("Health").dead,"Exploder active phase did not self-destruct"):
			return false
	if not actor.get_node("Health").dead:
		actor.get_node("Health").take_damage(1000,true)
	await create_timer(.06).timeout
	if not check(is_instance_valid(actor) and sprite.animation==&"death" and defeats[0]==1 and room._alive_enemies==0,role+": decorative death/progress missing"):
		return false
	var container := actor.get_parent()
	var budget := container.get_node_or_null("HostileAttackBudget")
	if not check(budget==null or budget.active_count()==0,role+": attack lease survives death"):
		return false
	var before: int = health.health
	await create_timer(.35).timeout
	if not check(not is_instance_valid(actor) and health.health==before and not room.portal.locked,role+": bounded cleanup/cancellation/portal failed"):
		return false
	_trace.append({"role":role,"pattern":pattern,"ratio":ratio,"emitted_tell_seconds":emitted[0],"damage_observed":100-before,"elapsed_ms":Time.get_ticks_msec()-started,"defeats":defeats[0]})
	room.queue_free()
	await process_frame
	return true

func _run() -> void:
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_remaining_art.json","user://rq_remaining_art.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	for role in ["ranged","charger","controller","exploder","storm_warden","rift_sovereign"]:
		var ratios: Array = [1.0,.4] if role=="storm_warden" else ([1.0,.5,.2] if role=="rift_sovereign" else [1.0])
		for ratio in ratios:
			if not await exercise(role,ratio):
				return
	for biome in ["castle","caves","hub"]:
		var room := room_for(biome)
		for landing in [Vector2(401,576),Vector2(527,576),Vector2(833,512),Vector2(959,512)]:
			room.player.position = landing-Vector2(0,60)
			room.player.velocity = Vector2.ZERO
			for _i in range(30):
				await physics_frame
			if not check(room.player.is_on_floor() and absf(room.player.position.y+26-landing.y)<1,biome+": platform edge differs from actual contact"):
				return
		var camera: Camera2D = room.player.get_node("Camera2D")
		camera.position.y = -154
		camera.limit_left = -640
		camera.limit_right = 1920
		var layers: Node2D = room.get_node("RemainingArtLayers")
		for x in [100,640,1180]:
			room.player.position.x = x
			camera.reset_smoothing()
			camera.force_update_scroll()
			layers.update_layers()
			var center := camera.get_screen_center_position()
			if not check(layers.panels[0].global_position.x<=center.x-640 and layers.panels[-1].global_position.x+1280>=center.x+640,biome+": background gap"):
				return
		room.queue_free()
		await process_frame
	if OS.get_cmdline_user_args().has("--save-art-trace"):
		var path := "res://../assets/production_drafts/2026-10-22/remaining-art-v01/INTEGRATION_TRACE.json"
		FileAccess.open(path,FileAccess.WRITE).store_string(JSON.stringify({"cases":_trace,"physical_device_acceptance":false},"\t"))
	print("RQ_REMAINING_ART_OK roles6 patterns9 actual_damage_death=pass biomes3 platform_edges12=aligned background_checkpoints9=pass")
	quit(0)
