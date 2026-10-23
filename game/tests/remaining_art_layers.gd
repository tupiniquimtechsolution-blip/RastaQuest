extends Node2D

const Art = preload("res://tests/art_review_fixtures.gd")
var biome := "castle"
var camera: Camera2D
var far_layer: Node2D
var mid_layer: Node2D
var foreground: Node2D
var panels: Array[Sprite2D] = []
var modules: Array[Sprite2D] = []
var front: Array[Sprite2D] = []
var _textures: Dictionary = {}

func sprite(parent: Node,file: String,at: Vector2) -> Sprite2D:
	var node := Sprite2D.new()
	node.centered = false
	node.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if not _textures.has(file):
		_textures[file] = Art.texture("remaining-art-v01/environments/"+biome+"/"+file)
	node.texture = _textures[file]
	node.position = at
	parent.add_child(node)
	return node

func build() -> void:
	z_index = -1
	far_layer = Node2D.new()
	add_child(far_layer)
	for _i in range(4):
		var bg := sprite(far_layer,"background.png",Vector2.ZERO)
		bg.modulate = Color(.42,.45,.49) if biome=="castle" else (Color(.48,.54,.58) if biome=="caves" else Color(.55,.55,.48))
		panels.append(bg)
	mid_layer = Node2D.new()
	add_child(mid_layer)
	for _i in range(6):
		var module := sprite(mid_layer,"prop_01.png",Vector2.ZERO)
		module.scale = Vector2(2,2)
		module.modulate = Color(.42,.46,.48,.60)
		modules.append(module)
	var terrain := Node2D.new()
	add_child(terrain)
	for y in range(6):
		for x in range(-24,106):
			var tile := sprite(terrain,"terrain_%s_%d.png"%["top" if y==0 else "soil",1+posmod(x*7+y*11,3)],Vector2(x*32,640+y*32))
			tile.modulate = Color(.85,.85,.85) if y==0 else Color(.42,.44,.46)
	for prop in [["prop_01.png",Vector2(100,512)],["prop_02.png",Vector2(1130,576)],["prop_04.png",Vector2(980,608)],["prop_05.png",Vector2(220,576)]]:
		sprite(terrain,prop[0],prop[1])
	for at in [Vector2(400,576),Vector2(832,512)]:
		var platform := StaticBody2D.new()
		platform.position = at+Vector2(64,16)
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(128,32)
		shape.shape = rectangle
		platform.add_child(shape)
		add_child(platform)
		for x in range(4):
			sprite(terrain,"terrain_"+("top_left" if x==0 else "top_right" if x==3 else "top_"+str(x+1))+".png",at+Vector2(x*32,0))
			sprite(terrain,"terrain_"+("bottom_left" if x==0 else "bottom_right" if x==3 else "bottom")+".png",at+Vector2(x*32,32))
	foreground = Node2D.new()
	foreground.z_index = 2
	add_child(foreground)
	for _i in range(5):
		var im := sprite(foreground,"prop_03.png",Vector2.ZERO)
		im.modulate = Color(.45,.48,.46,.70)
		front.append(im)
	update_layers()

func _process(_delta: float) -> void:
	update_layers()

func update_layers() -> void:
	if camera==null or not is_instance_valid(far_layer):
		return
	var center := camera.get_screen_center_position()
	far_layer.position = Vector2(roundf(center.x*.75),floorf(center.y-360))
	mid_layer.position.x = roundf(center.x*.35)
	foreground.position.x = roundf(center.x*-.08)
	var first := floori((center.x-far_layer.position.x-640)/1280)
	for i in range(panels.size()):
		panels[i].position = Vector2((first+i)*1280,0)
		panels[i].flip_h = posmod(first+i,2)==1
	first = floori((center.x-mid_layer.position.x-640)/512)-1
	for i in range(modules.size()):
		modules[i].position = Vector2((first+i)*512+80,384)
	first = floori((center.x-foreground.position.x-640)/512)-1
	for i in range(front.size()):
		front[i].position = Vector2((first+i)*512+24,652)
