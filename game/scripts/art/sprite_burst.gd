extends Node2D

var kind := "hit"
var lifetime := .24
var diameter := 64.0
var chain_end := Vector2.INF
var elapsed := 0.0
var _sprite: Sprite2D

func _ready() -> void:
	add_to_group("review_effect")
	z_index = 4
	_sprite = Sprite2D.new()
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.modulate.a = .72
	add_child(_sprite)
	_update_frame()

func _update_frame() -> void:
	_sprite.texture = get_node("/root/ArtCatalog").effect_frame(kind,elapsed,lifetime)
	if _sprite.texture!=null:
		_sprite.scale = Vector2(diameter,diameter)/_sprite.texture.get_size()
	if chain_end!=Vector2.INF:
		_sprite.position = chain_end*.5
		_sprite.rotation = chain_end.angle()
		if _sprite.texture!=null:
			_sprite.scale = Vector2(chain_end.length(),24)/_sprite.texture.get_size()

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed>=lifetime:
		queue_free()
		return
	_update_frame()
