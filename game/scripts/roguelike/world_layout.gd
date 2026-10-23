extends RefCounted

static func width_for(biome: StringName) -> int:
	return 4480 if biome == &"castle" else (4096 if biome == &"caves" else 3840)

static func platforms_for(biome: StringName) -> Array[Rect2]:
	var result: Array[Rect2] = []
	var base := 640 if biome == &"forest" else (960 if biome == &"castle" else 704)
	for i in range(3):
		result.append(Rect2(base+i*192,576-i*64,160 if biome != &"castle" else 192,32))
	result.append(Rect2(width_for(biome)-1248,544,256,32))
	result.append(Rect2(width_for(biome)-864,480,192,32))
	return result

static func configure(room: Node2D, biome: StringName) -> void:
	var width := width_for(biome)
	room.world_width = width
	room.platform_rects = platforms_for(biome)
	var ground: StaticBody2D = room.get_node("Ground")
	ground.position.x = width*0.5
	var shape := RectangleShape2D.new()
	shape.size = Vector2(width+120,80)
	ground.get_node("CollisionShape2D").shape = shape
	ground.get_node("GroundVisual").polygon = PackedVector2Array([Vector2(-width*.5-60,-40),Vector2(width*.5+60,-40),Vector2(width*.5+60,40),Vector2(-width*.5-60,40)])
	var old := room.get_node_or_null("RoutePlatforms")
	if old != null:
		old.free()
	var route := Node2D.new()
	route.name = "RoutePlatforms"
	room.add_child(route)
	for rect in room.platform_rects:
		var platform := StaticBody2D.new()
		platform.position = rect.get_center()
		var collider := CollisionShape2D.new()
		var box := RectangleShape2D.new()
		box.size = rect.size
		collider.shape = box
		platform.add_child(collider)
		var visual := Polygon2D.new()
		visual.name = "PlatformVisual"
		var half: Vector2 = rect.size*.5
		visual.polygon = PackedVector2Array([-half,Vector2(half.x,-half.y),half,Vector2(-half.x,half.y)])
		visual.color = Color(.28,.34,.24)
		platform.add_child(visual)
		route.add_child(platform)
	for x in [-40,width+40]:
		var wall := StaticBody2D.new()
		wall.position = Vector2(x,320)
		var collider := CollisionShape2D.new()
		var wall_shape := RectangleShape2D.new()
		wall_shape.size = Vector2(80,640)
		collider.shape = wall_shape
		wall.add_child(collider)
		route.add_child(wall)
	room.portal.position.x = width-180
	var camera: Camera2D = room.player.get_node("Camera2D")
	camera.limit_left = 0
	camera.limit_right = width
	camera.reset_smoothing()
