extends Node2D

## Proof-only camera-relative layers. Does not modify shipping camera/resources.
const Art = preload("res://tests/art_review_fixtures.gd")
var camera: Camera2D
var far_layer: Node2D
var mid_layer: Node2D
var foreground: Node2D
var _backgrounds: Array[Sprite2D] = []
var _trees: Array[Sprite2D] = []
var _ferns: Array[Sprite2D] = []
var far_origin := Vector2.ZERO

func sprite(parent: Node, file: String, at: Vector2, old := false) -> Sprite2D:
	var node := Sprite2D.new()
	node.texture = Art.texture(("forest-chaser-proof/" if old else "forest-chaser-polish/")+file)
	node.centered = false
	node.position = at
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(node)
	return node

func build() -> void:
	z_index = -1
	far_layer = Node2D.new()
	far_layer.name = "FarQuarterSpeed"
	add_child(far_layer)
	# Alternating mirrored panels share exact edge texels, unlike ordinary wrap
	# of a painted non-seamless image. Reflection periodicity remains reviewable.
	for _i in range(4):
		var bg := sprite(far_layer,"forest_background.png",Vector2.ZERO,true)
		bg.modulate = Color(0.52,0.59,0.58)
		_backgrounds.append(bg)
	mid_layer = Node2D.new()
	mid_layer.name = "MidSixtyFivePercent"
	add_child(mid_layer)
	for _i in range(7):
		var tree := sprite(mid_layer,"forest_tree.png",Vector2.ZERO,true)
		tree.scale = Vector2(2,2)
		tree.modulate = Color(0.38,0.47,0.43,0.65)
		_trees.append(tree)
	var ground := Node2D.new()
	ground.name = "ContactTerrain"
	add_child(ground)
	for y in range(6):
		for x in range(-24,106):
			var tile := sprite(ground,"terrain_%s_%d.png"%["top" if y==0 else "soil",1+posmod(x*7+y*11,3)],Vector2(x*32,640+y*32))
			tile.modulate = Color(0.70,0.75,0.66) if y==0 else Color(0.40,0.44,0.40)
	for at in [Vector2(400,576),Vector2(832,512)]:
		for x in range(4):
			var top := "top_left" if x==0 else ("top_right" if x==3 else "top_"+str(x+1))
			var bottom := "bottom_left" if x==0 else ("bottom_right" if x==3 else "bottom")
			sprite(ground,"terrain_"+top+".png",at+Vector2(x*32,0))
			# Roots below the32px collider are decoration, not another ledge.
			sprite(ground,"terrain_"+bottom+".png",at+Vector2(x*32,32))
	for item in [["forest_tree.png",Vector2(100,512)],["forest_column.png",Vector2(1150,544)],["forest_log.png",Vector2(245,608)],["forest_rubble.png",Vector2(980,608)]]:
		sprite(ground,item[0],item[1],true)
	foreground = Node2D.new()
	foreground.name = "ForegroundOneHundredEightPercent"
	foreground.z_index = 2
	add_child(foreground)
	for _i in range(5):
		var fern := sprite(foreground,"forest_fern_left.png",Vector2.ZERO,true)
		fern.modulate = Color(0.40,0.50,0.40,0.75)
		_ferns.append(fern)
	update_layers()

func _process(_delta: float) -> void:
	update_layers()

func update_layers() -> void:
	if camera == null or not is_instance_valid(far_layer):
		return
	var center := camera.get_screen_center_position()
	# The far painting fills the viewport vertically even at the jump apex.
	# Contact terrain and midground roots remain anchored in world coordinates.
	far_layer.position.x = roundf(center.x*0.75)
	far_layer.position.y = floorf(center.y-360.0)
	mid_layer.position.x = roundf(center.x*0.35)
	foreground.position.x = roundf(center.x*-0.08)
	var first := floori((center.x-far_layer.position.x-640.0)/1280.0)
	for i in range(_backgrounds.size()):
		var panel := first+i
		_backgrounds[i].position = Vector2(panel*1280,0)
		_backgrounds[i].flip_h = posmod(panel,2)==1
	var tree_first := floori((center.x-mid_layer.position.x-640.0)/384.0)-1
	for i in range(_trees.size()):
		_trees[i].position = Vector2((tree_first+i)*384+64,384)
	var fern_first := floori((center.x-foreground.position.x-640.0)/512.0)-1
	for i in range(_ferns.size()):
		_ferns[i].position = Vector2((fern_first+i)*512+24,652)
