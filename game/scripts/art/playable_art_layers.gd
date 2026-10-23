extends Node2D

var biome := "forest"
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
	add_child(_far)
	for _i in range(4):
		var panel := _sprite(_far,spec.background,Vector2.ZERO)
		# Lower contrast around small actors; retain bright contact boundary.
		panel.modulate = Color(.29,.32,.34)
		_panels.append(panel)
	var ground := Node2D.new()
	add_child(ground)
	# Match the existing 1400px ground collider. No new decorative platforms
	# masquerade as walkable geometry in this playable integration.
	for y in range(5):
		for x in range(-2,42):
			var name := ("top_" if y==0 else "soil_")+str(1+posmod(x*7+y*11,3))
			var tile := _sprite(ground,spec.tiles[name],Vector2(x*32,640+y*32))
			tile.modulate = Color(.90,.90,.85) if y==0 else Color(.38,.40,.40)
	# Sparse small scenery kept out of combat, portal and touch-control lanes.
	for i in range(mini(2,spec.props.size())):
		var prop := _sprite(ground,spec.props[-1-i],Vector2(40+i*1180,608))
		prop.modulate = Color(.48,.50,.48,.65)
	update_layers()
	return true

func _process(_delta: float) -> void:
	update_layers()

func update_layers() -> void:
	if not is_instance_valid(camera) or _far==null:
		return
	var center := camera.get_screen_center_position()
	_far.position = Vector2(roundf(center.x*.75),floorf(center.y-360))
	var first := floori((center.x-_far.position.x-640)/1280)
	for i in range(_panels.size()):
		_panels[i].position = Vector2((first+i)*1280,0)
		_panels[i].flip_h = posmod(first+i,2)==1
