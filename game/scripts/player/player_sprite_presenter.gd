extends Node2D

## Optional production art adapter. Never manufactures frames or changes combat.
const BODY_CLIPS := [&"idle", &"run", &"jump", &"fall", &"attack_axe", &"attack_axe_air", &"hurt", &"death"]
const SOURCE_FRAME := Vector2(256, 256)
const VISUAL_SCALE := Vector2(0.5, 0.5)

@export var sprite_frames: SpriteFrames
var _sprite: AnimatedSprite2D
var _player: Node

func _ready() -> void:
	_player = get_parent()
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "ProductionSprite"
	_sprite.centered = true
	_sprite.scale = VISUAL_SCALE
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	_player.movement_state_changed.connect(_show_state)
	if sprite_frames != null:
		apply_frames(sprite_frames)

func apply_frames(candidate: SpriteFrames) -> bool:
	# Validate the complete body set before hiding anything. Stale studies and
	# missing poses cannot silently replace gameplay's development visual.
	if candidate == null:
		return false
	for clip in BODY_CLIPS:
		if not candidate.has_animation(clip) or candidate.get_frame_count(clip) == 0:
			return false
		for index in range(candidate.get_frame_count(clip)):
			var texture := candidate.get_frame_texture(clip, index)
			if texture == null or texture.get_size() != SOURCE_FRAME:
				return false
	sprite_frames = candidate
	_sprite.sprite_frames = candidate
	_sprite.visible = true
	$Body.visible = false
	$Headband.visible = false
	_show_state(_player.current_animation_name())
	return true

func _show_state(animation_name: StringName) -> void:
	if _sprite.visible and animation_name in BODY_CLIPS:
		_sprite.play(animation_name)
	# Animation completion deliberately never changes hitboxes, damage, state,
	# portal transitions or actor lifetime; gameplay remains authoritative.
