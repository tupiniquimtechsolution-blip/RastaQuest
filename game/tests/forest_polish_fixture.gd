extends RefCounted

const Art = preload("res://tests/art_review_fixtures.gd")
const Old = preload("res://tests/forest_review_fixture.gd")
const Layers = preload("res://tests/forest_review_parallax.gd")

static func tex(file: String) -> Texture2D:
	return Art.texture("forest-chaser-polish/"+file)

static func manifest() -> Dictionary:
	return JSON.parse_string(FileAccess.get_file_as_string("res://../assets/production_drafts/2026-10-22/forest-chaser-polish/MANIFEST.json"))

static func chaser_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	for clip in [&"idle",&"move",&"tell",&"attack",&"hurt",&"death"]:
		frames.add_animation(clip)
		frames.set_animation_speed(clip,1000.0)
		frames.set_animation_loop(clip,clip in [&"idle",&"move"])
	for key in manifest().chaser.frames:
		frames.add_frame(key.clip,tex(key.file),key.duration_ms)
	return frames

static func build(room: Node) -> Node:
	var enemy: Node = Old.build(room)
	room.get_node("ForestReviewLayers").free()
	var layers := Layers.new()
	layers.name = "ForestPolishLayers"
	layers.camera = room.player.get_node("Camera2D")
	room.add_child(layers)
	layers.build()
	var frames := chaser_frames()
	enemy.apply_sprite_frames(frames)
	var keys := {}
	for key in manifest().chaser.frames:
		if not keys.has(key.clip):
			keys[key.clip] = []
		keys[key.clip].append(key)
	if not enemy.get_node("SpritePresenter").apply_equipment(tex("chaser_sword.png"),tex("chaser_shield.png"),keys):
		push_error("Rigid equipment packet rejected")
	# Separate traversal fixture: extend the floor only here, never shipping scene.
	var extension := StaticBody2D.new()
	extension.name = "ReviewFloorExtension"
	extension.position = Vector2(1920,680)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(1280,80)
	shape.shape = rect
	extension.add_child(shape)
	room.add_child(extension)
	return enemy
