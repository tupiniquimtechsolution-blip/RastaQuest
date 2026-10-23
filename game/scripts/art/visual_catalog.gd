extends Node

## Isolated visual-review payload. Commercial presets exclude its resources.
const PATH := "res://visual_review/catalog.json"
var catalog: Dictionary = {}
var _textures: Dictionary = {}
var _frames: Dictionary = {}
var installed := 0

func enabled() -> bool:
	return (OS.has_feature("visual_review") or "--visual-review" in OS.get_cmdline_user_args()) and FileAccess.file_exists(PATH)

func _ready() -> void:
	if not enabled():
		return
	var parsed = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	if not parsed is Dictionary or parsed.get("schema") != 1 or parsed.get("commercial_approved",true):
		push_error("Invalid visual-review catalog")
		return
	catalog = parsed
	get_tree().node_added.connect(func(node): _install.call_deferred(node))

func texture(file: String) -> Texture2D:
	if catalog.is_empty() or file.contains("..") or file.begins_with("/"):
		return null
	if not _textures.has(file):
		_textures[file] = load("res://visual_review/"+file) as Texture2D
	return _textures[file]

func frames(key: String, spec: Dictionary) -> SpriteFrames:
	if _frames.has(key):
		return _frames[key]
	var result := SpriteFrames.new()
	for clip in spec.clips:
		result.add_animation(clip)
		result.set_animation_speed(clip,1000)
		result.set_animation_loop(clip,clip in ["idle","run","move"])
		for item in spec.clips[clip]:
			var tex := texture(item.file)
			if tex==null or item.duration_ms<=0:
				return null
			result.add_frame(clip,tex,item.duration_ms)
	_frames[key] = result
	return result

func _install(node: Node) -> void:
	if not is_instance_valid(node) or not node.is_inside_tree() or catalog.is_empty() or node.get_script()==null:
		return
	var path: String = node.get_script().resource_path
	if path.ends_with("/player_controller.gd"):
		var visual := node.get_node("Visual")
		visual.dropped_weapon_texture = texture(catalog.player.dropped_weapon)
		if visual.apply_frames(frames("player",catalog.player)):
			visual.set_visual_size(1.15)
			installed += 1
	elif path.ends_with("/portal.gd"):
		if node.apply_frames(frames("portal",catalog.portal)):
			installed += 1
	elif path.ends_with("/enemy_base.gd"):
		if node.data!=null:
			apply_hostile(node,node.data.behavior)
	elif path.ends_with("/storm_warden.gd") or path.ends_with("/rift_sovereign.gd"):
		apply_hostile(node,"storm_warden" if path.ends_with("/storm_warden.gd") else "rift_sovereign")
	elif path.ends_with("/run_room_controller.gd"):
		apply_environment(node,String(RunManager.state.biome))
		var label := Label.new()
		label.name = "VisualReviewLabel"
		label.text = "review_version"
		label.position = Vector2(24,74)
		node.get_node("Hud").add_child(label)
	elif path.ends_with("/hub_controller.gd"):
		var bg := Sprite2D.new()
		bg.name = "ReviewHubBackground"
		bg.centered = false
		bg.texture = texture(catalog.environments.hub.background)
		bg.modulate = Color(.45,.45,.40)
		bg.z_index = -1
		node.add_child(bg)
		node.get_node("Backdrop").hide()
		var label := Label.new()
		label.text = "review_art"
		label.position = Vector2(40,100)
		node.add_child(label)

func apply_hostile(actor: Node, role: String) -> bool:
	if not catalog.actors.has(role):
		return false
	var spec: Dictionary = catalog.actors[role]
	var body := frames(role,spec)
	var presenter: Node
	if role=="chaser":
		if not actor.apply_sprite_frames(body):
			return false
		presenter = actor.get_node("SpritePresenter")
		if not presenter.apply_equipment(texture(spec.equipment.sword),texture(spec.equipment.shield),spec.equipment.keys):
			return false
	elif role in ["storm_warden","rift_sovereign"]:
		if not actor.apply_art_frames(body,spec.patterns):
			return false
	else:
		presenter = preload("res://scripts/enemies/hostile_art_presenter.gd").new()
		presenter.name = "ReviewArtPresenter"
		actor.add_child(presenter)
		if not presenter.apply_frames(body,spec.patterns,256):
			presenter.queue_free()
			return false
		actor._presenter = presenter
		if spec.has("equipment") and not presenter.apply_equipment(texture(spec.equipment.file),spec.equipment.grip,spec.equipment.keys):
			push_error("Rejected rigid equipment: "+role)
	if presenter == null:
		presenter = actor._art_presenter
	if is_instance_valid(presenter):
		var sprite: AnimatedSprite2D = presenter._sprite
		sprite.scale = Vector2.ONE*0.575
		sprite.position.y = -8.4 if role in ["storm_warden","rift_sovereign"] else -4.35
	var room := actor.get_parent().get_parent()
	if room.has_node("Ground/GroundVisual"):
		apply_environment(room,String(RunManager.state.biome))
	installed += 1
	return true

func apply_environment(room: Node, biome: String) -> void:
	if catalog.is_empty() or not catalog.environments.has(biome):
		return
	var old := room.get_node_or_null("PlayableArtLayers")
	if old!=null:
		if old.biome==biome and old.world_width==room.world_width:
			_hide_environment_placeholders(room)
			return
		old.free()
	var layers := preload("res://scripts/art/playable_art_layers.gd").new()
	layers.name = "PlayableArtLayers"
	layers.biome = biome
	layers.world_width = room.world_width
	layers.platform_rects = room.platform_rects
	layers.camera = room.player.get_node("Camera2D")
	# Framing proposal enabled only in the review flavor.
	layers.camera.position.y = -154
	layers.camera.limit_left = 0
	layers.camera.limit_right = room.world_width
	room.add_child(layers)
	if layers.build(catalog.environments[biome]):
		_hide_environment_placeholders(room)

func _hide_environment_placeholders(room: Node) -> void:
	room.get_node("Backdrop").hide()
	room.get_node("Ground/GroundVisual").hide()
	for platform in room.get_node("RoutePlatforms").get_children():
		if platform.has_node("PlatformVisual"):
			platform.get_node("PlatformVisual").hide()

func effect_frame(kind: String, elapsed: float, lifetime: float = .24) -> Texture2D:
	if catalog.is_empty() or not catalog.effects.has(kind):
		return null
	var keys: Array = catalog.effects[kind]
	var index := 1 if SettingsManager.reduced_flashes_enabled() and keys.size()>1 else clampi(int(elapsed/maxf(.01,lifetime)*keys.size()),0,keys.size()-1)
	return texture(keys[index])

func burst(kind: String, at: Vector2, context: Node, diameter := 64.0, lifetime := .24, end := Vector2.INF) -> Node:
	if catalog.is_empty() or not catalog.effects.has(kind) or not is_instance_valid(context):
		return null
	var root := context.get_tree().current_scene
	if root==null:
		root = context.get_parent()
	if root==null:
		return null
	# Presentation cap; no gameplay attack lease or damage is modified.
	var living := get_tree().get_nodes_in_group("review_effect").filter(func(effect): return not effect.is_queued_for_deletion())
	if living.size()>=24:
		living[0].queue_free()
	var fx := preload("res://scripts/art/sprite_burst.gd").new()
	fx.kind = kind
	fx.diameter = diameter
	fx.lifetime = clampf(lifetime,.05,.8)
	fx.chain_end = end-at if end!=Vector2.INF else Vector2.INF
	root.add_child(fx)
	fx.global_position = at
	return fx
