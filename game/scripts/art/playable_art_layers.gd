extends Node2D

var biome := "forest"
var world_width := 3840
var platform_rects: Array[Rect2] = []
var _tiles: Dictionary = {}
var camera: Camera2D
var _panels: Array[Sprite2D] = []
var _far: Node2D

func _sprite(parent: Node, file: String, at: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = get_node("/root/ArtCatalog").texture(file)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.centered = false
	sprite.position = at
	parent.add_child(sprite)
	return sprite

func build(spec: Dictionary) -> bool:
	if get_node("/root/ArtCatalog").texture(spec.background)==null:
		return false
	z_index = -1
	_far = Node2D.new()
	_far.z_index = -1
	add_child(_far)
	for _i in range(4):
		var panel := _sprite(_far,spec.background,Vector2.ZERO)
		# Lower contrast around small actors; retain bright contact boundary.
		panel.modulate = Color(.29,.32,.34)
		_panels.append(panel)
	var ground := Node2D.new()
	add_child(ground)
	_tiles = spec.tiles
	for rect in platform_rects:
		for x in range(int(rect.size.x/32)):
			_sprite(ground,spec.tiles["top_"+str(1+posmod(x,3))],rect.position+Vector2(x*32,0))
	# Sparse small scenery kept out of combat, portal and touch-control lanes.
	for i in range(mini(2,spec.props.size())):
		var prop := _sprite(ground,spec.props[-1-i],Vector2(40+i*1180,608))
		prop.modulate = Color(.48,.50,.48,.65)
	update_layers()
	queue_redraw()
	return true

func _process(_delta: float) -> void:
	update_layers()
	queue_redraw()

func update_layers() -> void:
	if not is_instance_valid(camera) or _far==null:
		return
	var center := camera.get_screen_center_position()
	_far.position = Vector2(roundf(center.x*.75),floorf(center.y-360))
	var first := floori((center.x-_far.position.x-640)/1280)
	for i in range(_panels.size()):
		_panels[i].position = Vector2((first+i)*1280,0)
		_panels[i].flip_h = posmod(first+i,2)==1

func _draw() -> void:
	if _tiles.is_empty() or not is_instance_valid(camera):
		return
	var center := camera.get_screen_center_position()
	var first := maxi(-2,floori((center.x-680)/32))
	var last := mini(ceili((world_width+60)/32.0),ceili((center.x+680)/32))
	for y in range(5):
		for x in range(first,last):
			var key := ("top_" if y == 0 else "soil_")+str(1+posmod(x*7+y*11,3))
			var texture: Texture2D = get_node("/root/ArtCatalog").texture(_tiles[key])
			if texture != null:
				draw_texture_rect(texture,Rect2(x*32,640+y*32,32,32),false,Color(.9,.9,.85) if y==0 else Color(.38,.4,.4))
