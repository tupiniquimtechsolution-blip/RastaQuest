extends RefCounted

const Art = preload("res://tests/art_review_fixtures.gd")
const Enemy = preload("res://scenes/enemies/EnemyBase.tscn")

static func tex(file: String) -> Texture2D:
	return Art.texture("forest-chaser-proof/"+file)

static func sprite(parent: Node, file: String, at: Vector2) -> Sprite2D:
	var im := Sprite2D.new()
	im.texture = tex(file)
	im.centered = false
	im.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	im.position = at
	parent.add_child(im)
	return im

static func chaser_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	var clips := {&"idle":[240],&"move":[120,120],&"tell":[250],&"attack":[160],&"hurt":[100],&"death":[320]}
	for clip in clips:
		frames.add_animation(clip)
		frames.set_animation_speed(clip,1000.0)
		frames.set_animation_loop(clip,clip in [&"idle",&"move"])
		for i in range(clips[clip].size()):
			frames.add_frame(clip,tex("chaser_%s_%02d.png"%[clip,i+1]),clips[clip][i])
	return frames

static func build(room: Node) -> Node:
	room.get_node("Backdrop").visible = false
	room.get_node("Ground/GroundVisual").visible = false
	var environment := Node2D.new()
	environment.name = "ForestReviewLayers"
	environment.z_index = -1
	room.add_child(environment)
	var bg := sprite(environment,"forest_background.png",Vector2(-1280,0))
	bg.region_enabled = true
	bg.region_rect = Rect2(0,0,3840,720)
	bg.texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	bg.modulate = Color(0.55,0.61,0.60)
	for item in [["forest_tree.png",Vector2(100,512)],["forest_column.png",Vector2(1150,544)],["forest_log.png",Vector2(245,608)],["forest_rubble.png",Vector2(980,608)]]:
		sprite(environment,item[0],item[1])
	for yy in range(16):
		for xx in range(-2,43):
			var tile := sprite(environment,"terrain_top_32.png" if yy==0 else "terrain_soil_32.png",Vector2(xx*32,640+yy*32))
			var value := maxf(0.38,1.0-float(yy)*0.10)
			tile.modulate = Color(value,value,value)
	for at in [Vector2(400,576),Vector2(832,512)]:
		var platform := StaticBody2D.new()
		platform.name = "ReviewPlatform"
		platform.position = at+Vector2(64,16)
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(128,32)
		shape.shape = rect
		platform.add_child(shape)
		room.add_child(platform)
		for x in range(4):
			sprite(environment,"terrain_top_32.png",at+Vector2(x*32,0))
	for item in [["forest_fern_left.png",Vector2(40,620)],["forest_fern_right.png",Vector2(1200,620)]]:
		var fern := sprite(environment,item[0],item[1])
		fern.z_index = 2
	var enemy := Enemy.instantiate()
	enemy.name = "ChaserReview"
	enemy.data = load("res://data/enemies/chaser.tres").duplicate()
	enemy.target_path = NodePath("../../Player")
	enemy.position = Vector2(800,611)
	enemy.enemy_defeated.connect(room._on_enemy_defeated)
	room.get_node("Enemies").add_child(enemy)
	room._alive_enemies = 1
	room.portal.set_locked(true)
	enemy.apply_sprite_frames(chaser_frames())
	return enemy
