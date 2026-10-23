extends RefCounted

const Presenter = preload("res://scripts/enemies/hostile_art_presenter.gd")
const Art = preload("res://tests/art_review_fixtures.gd")
const Layers = preload("res://tests/remaining_art_layers.gd")

static func manifest() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://../assets/production_drafts/2026-10-22/remaining-art-v01/MANIFEST.json"))

static func texture(file: String) -> Texture2D:
	return Art.texture("remaining-art-v01/"+file)

static func frames(role: String) -> SpriteFrames:
	var result := SpriteFrames.new()
	for key in manifest().actors[role].frames:
		var clip := StringName(key.clip)
		if not result.has_animation(clip):
			result.add_animation(clip)
			result.set_animation_speed(clip,1000)
			result.set_animation_loop(clip,clip in [&"idle",&"move"])
		result.add_frame(clip,texture(key.file),key.duration_ms)
	return result

static func environment(room: Node, biome: String) -> Node2D:
	room.get_node("Backdrop").visible = false
	room.get_node("Ground/GroundVisual").visible = false
	var layers := Layers.new()
	layers.name = "RemainingArtLayers"
	layers.biome = biome
	layers.camera = room.player.get_node("Camera2D")
	room.add_child(layers)
	layers.build()
	return layers

static func enemy(room: Node, role: String) -> CharacterBody2D:
	var actor: CharacterBody2D = load("res://scenes/enemies/EnemyBase.tscn").instantiate()
	actor.data = load("res://data/enemies/"+role+".tres").duplicate()
	actor.target_path = NodePath("../../Player")
	actor.position = Vector2(800,611)
	actor.enemy_defeated.connect(room._on_enemy_defeated)
	room.get_node("Enemies").add_child(actor)
	var presenter := Presenter.new()
	presenter.name = "RosterPresenter"
	actor.add_child(presenter)
	# Review-only assignment uses existing bounded EnemyBase death adapter.
	actor._presenter = presenter
	if not presenter.apply_frames(frames(role),manifest().actors[role].patterns,256):
		push_error("Rejected role source packet: "+role)
	room._alive_enemies += 1
	room.portal.set_locked(true)
	return actor

static func boss(room: Node, role: String) -> CharacterBody2D:
	var path := "StormWarden" if role=="storm_warden" else "RiftSovereign"
	var actor: CharacterBody2D = load("res://scenes/boss/"+path+".tscn").instantiate()
	actor.target_path = NodePath("../Player")
	actor.position = Vector2(850,584)
	room.add_child(actor)
	actor.boss_defeated.connect(func():
		room._on_boss_defeated()
		room.status_label.text = role.to_upper()+" • derrota na sala de revisão"
	)
	room._alive_enemies = 1
	room.portal.set_locked(true)
	if not actor.apply_art_frames(frames(role),manifest().actors[role].patterns):
		push_error("Rejected boss source packet: "+role)
	return actor
