extends SceneTree

var _captures: Array = []
var _capture := false
var _output := "res://../assets/production_drafts/2026-10-23/a13-feedback-v02/room-review/"

func _init() -> void:
	call_deferred("_run")

func require(ok: bool, message: String) -> bool:
	if not ok:
		push_error("Visual review: "+message)
		quit(1)
	return ok

func snapshot(name: String, state: Dictionary = {}) -> void:
	if not _capture:
		return
	await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	for reduced in [false,true]:
		var output := image.duplicate()
		if reduced:
			output.resize(640,360,Image.INTERPOLATE_NEAREST)
		var file := name+("_640x360.png" if reduced else "_1280x720.png")
		output.save_png(_output+file)
		_captures.append({"file":file,"sha256":FileAccess.get_sha256(_output+file),"size":[output.get_width(),output.get_height()],"state":state})

func make_room(biome: String) -> Node:
	root.get_node("RunManager").start_run(31337)
	root.get_node("RunManager").state.biome = StringName(biome)
	var room: Node = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(room)
	current_scene = room
	return room

func clear_room(room: Node) -> void:
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(false)

func exercise(role: String,ratio: float) -> bool:
	var catalog: Node = root.get_node("ArtCatalog")
	var room := make_room("castle" if role in ["ranged","storm_warden"] else "caves")
	clear_room(room)
	await process_frame
	var boss := role in ["storm_warden","rift_sovereign"]
	var actor: CharacterBody2D
	if boss:
		actor = load("res://scenes/boss/"+("StormWarden" if role=="storm_warden" else "RiftSovereign")+".tscn").instantiate()
	else:
		actor = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
		actor.data = load("res://data/enemies/"+role+".tres").duplicate()
	actor.target_path = NodePath("../../Player")
	actor.position = Vector2(880 if role=="ranged" else 720,584 if boss else 611)
	room.get_node("Enemies").add_child(actor)
	actor.get_node("Health").health = maxi(1,roundi(actor.get_node("Health").max_health*ratio))
	room.player.position = Vector2(640,614)
	room.player.set_physics_process(false)
	room.player.get_node("Health").max_health = 100
	room.player.get_node("Health").reset_health()
	await process_frame
	await process_frame
	var presenter: Node = actor.get_node("ArtPresenter" if boss else "ReviewArtPresenter")
	if not require(presenter!=null and not actor.get_node("Visual").visible,role+" fallback polygon still visible"):
		return false
	var sprite: AnimatedSprite2D = presenter.get_node("HostileSprite")
	if role in ["ranged","controller"]:
		var master: Texture2D = presenter.get_node("HostileSprite/RigidEquipment/Item").texture
		for clip in ["idle","move","tell","attack","hurt","death"]:
			for index in range(sprite.sprite_frames.get_frame_count(clip)):
				sprite.play(clip);sprite.pause();sprite.frame=index
				for flip in [false,true]:
					sprite.flip_h=flip;presenter._sync_equipment()
					var rig: Node2D = sprite.get_node("RigidEquipment")
					if not require(rig.scale.x==(-1 if flip else 1) and rig.get_node("Item").texture==master,role+" master changed or mirror failed"):
						return false
		# A rejected rig must preserve the previously assigned valid equipment.
		if not require(not presenter.apply_equipment(master,[0,0],{}) and sprite.get_node("RigidEquipment/Item").texture==master,role+" invalid rig replaced valid master"):
			return false
		sprite.play("idle")
	var tell_seen := false
	var active_seen := false
	var pattern := ""
	for _i in range(230):
		await physics_frame
		await process_frame
		if not is_instance_valid(actor):
			break
		var attack = actor._attack
		if is_instance_valid(attack):
			pattern = String(attack.kind)
			var pair: Array = catalog.catalog.actors[role].patterns[pattern]
			if attack.phase==&"tell" and sprite.animation==StringName(pair[0]) and not tell_seen:
				tell_seen = true
				await snapshot(role+"_"+pattern+"_tell",{"pattern":pattern,"phase":"tell","clip":String(sprite.animation)})
			if attack.phase==&"active" and sprite.animation==StringName(pair[1]) and not active_seen:
				active_seen = true
				await snapshot(role+"_"+pattern+"_active",{"pattern":pattern,"phase":"active","clip":String(sprite.animation)})
		if tell_seen and active_seen and room.player.get_node("Health").health<100:
			break
	if not require(tell_seen and active_seen and room.player.get_node("Health").health<100,role+" actual phase/damage missing"):
		return false
	actor.get_node("Health").take_damage(1000,true)
	await create_timer(.08).timeout
	if not require(is_instance_valid(actor) and sprite.animation==&"death",role+" bounded death absent"):
		return false
	await create_timer(.36).timeout
	if not require(not is_instance_valid(actor),role+" death exceeded bounded lifetime"):
		return false
	room.queue_free()
	await process_frame
	return true

func _run() -> void:
	var catalog: Node = root.get_node_or_null("ArtCatalog")
	var save: Node = root.get_node_or_null("SaveManager")
	if not require(catalog!=null and save!=null,"packaged project/autoload configuration absent"):
		return
	save.configure_paths("user://rq_visual_playable.json","user://rq_visual_playable.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	_capture = "--capture-visual-review" in OS.get_cmdline_user_args()
	if _capture:
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(_output))
	if not require(catalog.enabled() and catalog.catalog.actors.size()==7,"flavor or catalog absent"):
		return
	var hub: Node = load("res://scenes/hub/Hub.tscn").instantiate()
	root.add_child(hub);current_scene=hub
	await process_frame;await process_frame
	if not require(hub.has_node("ReviewHubBackground") and not hub.get_node("Backdrop").visible,"Hub background absent"):
		return
	await snapshot("hub_playable",{"menu":"actual_hub","automatic_assignment":true})
	hub.queue_free();await process_frame
	for biome in ["forest","castle","caves"]:
		var room := make_room(biome)
		await process_frame;await process_frame
		if not require(room.has_node("PlayableArtLayers") and not room.get_node("Ground/GroundVisual").visible and not room.player.get_node("Visual/Body").visible and not room.portal.get_node("Visual").visible,biome+" placeholders not replaced"):
			return
		await snapshot(biome+"_playable",{"biome":biome,"automatic_assignment":true})
		clear_room(room)
		await process_frame
		room._on_portal_entered()
		var sprite: AnimatedSprite2D = room.player.get_node("Visual/ProductionSprite")
		if not require(sprite.animation==&"portal_enter" and not room.player.get_node("PlayerCombat").try_attack(),"dedicated portal body or input guard missing"):
			return
		await create_timer(.16).timeout
		await snapshot(biome+"_portal",{"clip":String(sprite.animation),"frame":sprite.frame})
		room.player.get_node("Health").take_damage(1,true)
		if not require(not room.player.is_entering_portal() and is_equal_approx(sprite.modulate.a,1),"portal interruption retained fade/lock"):
			return
		var settings: Node = root.get_node("SettingsManager")
		settings.set_value(&"reduced_flashes",true)
		if not require(catalog.effect_frame("electric_area",0)==catalog.effect_frame("electric_area",.2),"reduced flashes changed effect key"):
			return
		var fx: Node = catalog.burst("electric_area",room.player.position,room,116,.20)
		if not require(fx!=null,"FX binding absent"):
			return
		await create_timer(.24).timeout
		if not require(not is_instance_valid(fx),"effect lifetime not bounded"):
			return
		settings.set_value(&"reduced_flashes",false)
		room.queue_free();await process_frame
	# Accepted primary and secondary damage must create their own presentation;
	# a rejected contact or visual burst never schedules extra damage.
	var arena := make_room("forest")
	clear_room(arena);await process_frame;await process_frame
	var victims: Array = []
	for x in [222,320]:
		var victim: CharacterBody2D = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
		victim.data = load("res://data/enemies/chaser.tres").duplicate()
		victim.position = Vector2(x,611)
		arena.get_node("Enemies").add_child(victim)
		victim.set_physics_process(false)
		victim.get_node("Health").max_health = 10
		victim.get_node("Health").health = 1 if x==222 else 10
		victims.append(victim)
	arena.player.position=Vector2(180,614)
	for _i in range(5):await physics_frame
	var combat: Node = arena.player.get_node("PlayerCombat")
	combat.electrical_proc_chance=1
	combat.chain_lightning_enabled=true
	combat.on_kill_aoe_enabled=true
	var observation := {"primary_dead":false,"secondary_health":10.0,"kinds":[]}
	# Observe the accepted hit after PlayerCombat applies damage and effects.
	# Sampling a fixed wall-clock instant can miss short effects on CI.
	combat.hitbox.landed_hit.connect(func(target, _payload):
		if target != victims[0].get_node("Hurtbox"):
			return
		var observed_kinds: Array = []
		for effect in get_nodes_in_group("review_effect"):
			observed_kinds.append(effect.kind)
		observation.primary_dead = victims[0].get_node("Health").dead
		observation.secondary_health = victims[1].get_node("Health").health
		observation.kinds = observed_kinds
	)
	if not require(combat.try_attack(),"actual primary attack rejected"):
		return
	for _i in range(30):
		await physics_frame
		await process_frame
		if observation.primary_dead:
			break
	var kinds: Array = observation.kinds
	if not require(observation.primary_dead and observation.secondary_health<10 and "hit" in kinds and "electric_chain" in kinds and "electric_onkill" in kinds,"accepted primary/secondary hit FX binding missing: "+str(observation)):
		return
	await snapshot("actual_hit_chain_onkill",{"effect_kinds":kinds,"secondary_health":observation.secondary_health})
	await create_timer(.35).timeout
	if not require(get_nodes_in_group("review_effect").is_empty(),"one-shot impact effects survived lifetime"):
		return
	arena.queue_free();await process_frame
	for role in ["ranged","charger","controller","exploder","storm_warden","rift_sovereign"]:
		# Full attack/tell/death cases use actual actors and hazard scheduling.
		var ratios: Array = [1.0,.4] if role=="storm_warden" else ([1.0,.5,.2] if role=="rift_sovereign" else [1.0])
		for ratio in ratios:
			if not await exercise(role,ratio):
				return
	if _capture:
		var hashes := {}
		for file in ["res://project.godot","res://scripts/art/visual_catalog.gd","res://scripts/art/playable_art_layers.gd","res://scripts/art/sprite_burst.gd","res://scripts/art/visual_review_probe.gd","res://scripts/player/player_sprite_presenter.gd","res://scripts/player/player_combat.gd","res://scripts/enemies/hostile_art_presenter.gd","res://scripts/combat/hostile_attack.gd","res://scripts/roguelike/run_room_controller.gd","res://visual_review/catalog.json"]:
			hashes[file] = FileAccess.get_file_as_string(file).replace("\r\n","\n").sha256_text()
		var report := {"captures":_captures,"engine":Engine.get_version_info().string,"adapter":RenderingServer.get_video_adapter_name(),"human_acceptance":"PENDING","commercial_approved":false,"source_hashes":hashes,"hash_format":"UTF8 normalized LF"}
		FileAccess.open(_output+"RENDER_REPORT.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	print("RQ_VISUAL_REVIEW_OK automatic_assignment=pass actors7 patterns9 rigid_equipment=mirrored portal_body=cancellable effects=actual_hits_bounded_static biomes3 hub=pass commercial_approved=false")
	quit(0)
