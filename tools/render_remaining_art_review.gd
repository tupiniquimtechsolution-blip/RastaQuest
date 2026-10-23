extends SceneTree

const Fixture = preload("res://tests/remaining_art_fixture.gd")
const Hero = preload("res://tests/art_review_fixtures.gd")
var _room: Node
var _actor: Node
var _output: String
var _records: Array = []
var _mode := "material proof"

func _init() -> void:
	call_deferred("_run")

func capture(name: String) -> void:
	for _i in range(3):
		await process_frame
	await RenderingServer.frame_post_draw
	var im := root.get_texture().get_image()
	if im==null or im.is_empty() or im.save_png(_output.path_join(name+".png"))!=OK:
		push_error("Capture failed: "+name)
		quit(1)
		return
	var c: Camera2D = _room.player.get_node("Camera2D")
	var center := c.get_screen_center_position()
	var r := {"file":name+".png","size":[im.get_width(),im.get_height()],"sha256":FileAccess.get_sha256(_output.path_join(name+".png")),"mode":_mode,"camera_center":[center.x,center.y],"camera_local_y":c.position.y,"phase":"none","kind":"none","clip":"none"}
	if is_instance_valid(_actor):
		var a = _actor._attack
		if is_instance_valid(a):
			r.phase = String(a.phase)
			r.kind = String(a.kind)
		var p: Node = _actor.get_node_or_null("ArtPresenter")
		if p==null:
			p = _actor.get_node_or_null("RosterPresenter")
		if p!=null:
			var sprite: AnimatedSprite2D = p.get_node("HostileSprite")
			r.clip = String(sprite.animation)
			r.frame = sprite.frame
			r.tell_seconds = p._tell
			r.dead = _actor.get_node("Health").dead
	_records.append(r)

func new_room(biome: String) -> void:
	# Let bounded death coroutines finish before discarding their review world.
	if is_instance_valid(_actor) and _actor.get_node("Health").dead:
		await create_timer(.35).timeout
	_actor = null
	if is_instance_valid(_room):
		_room.queue_free()
		await process_frame
	root.get_node("RunManager").start_run(424242)
	_room = load("res://scenes/world/RunPrototypeRoom.tscn").instantiate()
	root.add_child(_room)
	current_scene = _room
	_room._clear_enemies()
	_room._alive_enemies = 0
	Hero.assign(_room.player,_room.portal)
	Fixture.environment(_room,biome)
	_room.player.position = Vector2(640,614)
	_room.player.get_node("Health").max_health = 100
	_room.player.get_node("Health").reset_health()
	_room.player.set_physics_process(false)
	var camera: Camera2D = _room.player.get_node("Camera2D")
	camera.position.y = -154
	camera.limit_left = 0
	camera.limit_right = 1280
	camera.reset_smoothing()
	_room.status_label.text = biome.to_upper()+" • ARTES v01 • sala de revisão / enquadramento proposto"
	for _i in range(5):
		await process_frame

func both_sizes(name: String) -> void:
	for size in [Vector2i(1280,720),Vector2i(640,360)]:
		root.size = size
		await capture(name+"_%dx%d"%[size.x,size.y])
	root.size = Vector2i(1280,720)

func combat(role: String,ratio: float) -> void:
	await new_room("castle" if role in ["ranged","storm_warden"] else "caves")
	_actor = Fixture.boss(_room,role) if role in ["storm_warden","rift_sovereign"] else Fixture.enemy(_room,role)
	_actor.set_physics_process(false)
	_actor.get_node("Health").health = maxi(1,roundi(_actor.get_node("Health").max_health*ratio))
	_actor.position = Vector2(880 if role=="ranged" else 720,584 if role in ["storm_warden","rift_sovereign"] else 611)
	_actor._physics_process(0.0) # Real AI/pattern/HostileAttack, movement held for inspection.
	await process_frame
	await process_frame
	var a = _actor._attack
	if not is_instance_valid(a):
		push_error("Could not start real attack: "+role)
		quit(1)
		return
	var kind: String = a.kind
	_mode = "actual tell/active phase; actor motion held; scene paused for inspection"
	paused = true
	await capture(role+"_"+kind+"_tell")
	paused = false
	var presenter: Node = _actor.get_node("ArtPresenter" if role in ["storm_warden","rift_sovereign"] else "RosterPresenter")
	var sprite: AnimatedSprite2D = presenter.get_node("HostileSprite")
	var expected: String = Fixture.manifest().actors[role].patterns[kind][1]
	var seen := false
	for _i in range(180):
		await process_frame
		if not is_instance_valid(_actor):
			break
		if is_instance_valid(a) and a.phase==&"active" and String(sprite.animation)==expected:
			seen = true
			break
	if not seen:
		push_error("Missed active art: "+role)
		quit(1)
		return
	paused = true
	await capture(role+"_"+kind+"_active")
	paused = false
	if ratio==1.0:
		_actor.get_node("Health").take_damage(1000,true)
		seen = false
		for _i in range(60):
			await process_frame
			if not is_instance_valid(_actor):
				break
			if sprite.animation==&"death" and sprite.frame==1:
				seen = true
				break
		if not seen:
			push_error("Missed actual fallen key: "+role)
			quit(1)
			return
		paused = true
		_mode = "actual fatal damage/cancellation and fallen key; paused before bounded removal"
		await capture(role+"_death")
		paused = false

func _run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Real desktop renderer required")
		quit(1)
		return
	_output = ProjectSettings.globalize_path("res://../assets/production_drafts/2026-10-22/remaining-art-v01/room-review")
	DirAccess.make_dir_recursive_absolute(_output)
	root.size = Vector2i(1280,720)
	root.content_scale_size = Vector2i(1280,720)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_render_remaining.json","user://rq_render_remaining.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("SettingsManager").reload_from_save()
	for biome in ["castle","caves","hub"]:
		await new_room(biome)
		_mode = "material proof in RunPrototypeRoom fixture; not shipping Hub integration"
		await both_sizes(biome+"_room")
		var camera: Camera2D = _room.player.get_node("Camera2D")
		camera.limit_left = -640
		camera.limit_right = 1920
		for x in [100,1180]:
			_room.player.position.x = x
			camera.reset_smoothing()
			camera.force_update_scroll()
			await capture(biome+"_wrap_"+str(x))
	await new_room("castle")
	_mode = "unlabeled static lineup of five enemies; no recognition responses inferred"
	_room.player.position.x = 180
	var n := 0
	for role in ["ranged","charger","controller","exploder"]:
		var actor := Fixture.enemy(_room,role)
		actor.position.x = 520+n*170
		actor.set_physics_process(false)
		n += 1
	var chaser: Node = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
	chaser.data = load("res://data/enemies/chaser.tres")
	chaser.position = Vector2(350,611)
	_room.get_node("Enemies").add_child(chaser)
	chaser.set_physics_process(false)
	var old: Script = load("res://tests/forest_polish_fixture.gd")
	chaser.apply_sprite_frames(old.chaser_frames())
	var keys := {}
	for key in old.manifest().chaser.frames:
		if not keys.has(key.clip):keys[key.clip] = []
		keys[key.clip].append(key)
	chaser.get_node("SpritePresenter").apply_equipment(old.tex("chaser_sword.png"),old.tex("chaser_shield.png"),keys)
	await both_sizes("roster_lineup")
	# Separate collision overlay exposes the low Charger's unchanged tall box.
	for actor in _room.get_node("Enemies").get_children():
		if not actor is CharacterBody2D:continue
		var size: Vector2 = actor.get_node("CollisionShape2D").shape.size
		var polygon := Polygon2D.new()
		polygon.polygon = PackedVector2Array([Vector2(-size.x/2,-size.y/2),Vector2(size.x/2,-size.y/2),Vector2(size.x/2,size.y/2),Vector2(-size.x/2,size.y/2)])
		polygon.color = Color(1,.65,.1,.28)
		actor.add_child(polygon)
	_mode = "actual collider overlay, geometry unchanged; low Charger silhouette mismatch deliberately visible"
	await capture("roster_collision_overlay")
	await new_room("caves")
	_mode = "static scale comparison of both boss candidates; art accepted status pending"
	_room.player.position.x = 200
	for pair in [["storm_warden",650],["rift_sovereign",1000]]:
		var actor := Fixture.boss(_room,pair[0])
		actor.position.x = pair[1]
		actor.set_physics_process(false)
	await both_sizes("boss_lineup")
	for role in ["ranged","charger","controller","exploder","storm_warden","rift_sovereign"]:
		for ratio in ([1.0,.4] if role=="storm_warden" else [1.0,.5,.2] if role=="rift_sovereign" else [1.0]):
			await combat(role,ratio)
	await new_room("hub")
	_mode = "shared FX source gallery, independently staged; not gameplay hazard authority"
	var index := 0
	for effect in ["hit","hostile_projectile","hostile_area","reward"]:
		for frame in Fixture.manifest().effects[effect].frames:
			var im := Sprite2D.new()
			im.texture = Fixture.texture(frame.file)
			im.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			im.position = Vector2(350+(index%3)*160,220+(index/3)*90)
			_room.add_child(im)
			index += 1
	await both_sizes("shared_fx_gallery")
	await new_room("caves")
	_mode = "player electric source gallery; anchors and gameplay binding pending"
	index = 0
	for effect in ["electric_chain","electric_area","electric_onkill"]:
		for frame in Fixture.manifest().effects[effect].frames:
			var im := Sprite2D.new()
			im.texture = Fixture.texture(frame.file)
			im.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			im.scale = Vector2(.5,.5)
			im.position = Vector2(350+(index%3)*160,250+(index/3)*100)
			_room.add_child(im)
			index += 1
	await both_sizes("electric_fx_gallery")
	await new_room("hub")
	_room.player.position.x = 160
	_mode = "four new portal BODY candidates with rigid axe; independent keys, current quiet portal runtime unchanged"
	for key in Fixture.manifest().portal_body.frames:
		var im := Sprite2D.new()
		im.texture = Fixture.texture(key.combined_file)
		im.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		im.scale = Vector2(.5,.5)
		im.position = Vector2(400+(key.index-1)*200,614)
		_room.add_child(im)
	await both_sizes("portal_body_gallery")
	var hashes := {}
	for path in ["res://scripts/enemies/hostile_art_presenter.gd","res://scripts/boss/storm_warden.gd","res://scripts/boss/rift_sovereign.gd","res://scripts/combat/hostile_attack.gd","res://tests/remaining_art_fixture.gd","res://tests/remaining_art_layers.gd","res://tests/art_review_fixtures.gd","res://../tools/render_remaining_art_review.gd","res://../assets/production_drafts/2026-10-22/remaining-art-v01/MANIFEST.json"]:
		hashes[path] = FileAccess.get_file_as_string(path).replace("\r\n","\n").sha256_text()
	FileAccess.open(_output.path_join("RENDER_REPORT.json"),FileAccess.WRITE).store_string(JSON.stringify({"engine":Engine.get_version_info().string,"driver":RenderingServer.get_video_adapter_name(),"captures":_records,"source_hashes":hashes,"hash_text_format":"UTF-8 normalized LF","human_acceptance":"PENDING","runtime_asset_promotion":false,"framing":"review-only y-154; original production camera unchanged"},"\t"))
	print("RQ_REMAINING_ART_RENDER_OK captures=",_records.size()," driver=",RenderingServer.get_video_adapter_name())
	_room.queue_free()
	await process_frame
	await process_frame
	quit(0)
