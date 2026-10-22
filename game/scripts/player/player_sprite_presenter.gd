extends Node2D

## Optional production art adapter. Never manufactures frames or changes combat.
const BODY_CLIPS := [&"idle", &"run", &"jump", &"fall", &"attack_axe", &"attack_axe_air", &"hurt", &"death"]
const SOURCE_FRAME := Vector2(256, 256)
const VISUAL_SCALE := Vector2(0.5, 0.5)
const MAX_DEATH_PRESENTATION_SECONDS := 1.5

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
		if candidate.get_animation_speed(clip) <= 0.0:
			return false
		if clip not in [&"idle", &"run"] and candidate.get_animation_loop(clip):
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

func death_presentation_seconds() -> float:
	# Without assigned complete art, preserve the existing immediate fallback.
	# Bounded gameplay timer, never an animation_finished lifetime dependency.
	if sprite_frames == null or not _sprite.visible:
		return 0.0
	var seconds := 0.0
	var speed := sprite_frames.get_animation_speed(&"death")
	for index in range(sprite_frames.get_frame_count(&"death")):
		seconds += sprite_frames.get_frame_duration(&"death", index) / speed
	return clampf(seconds, 0.0, MAX_DEATH_PRESENTATION_SECONDS)

func _show_state(animation_name: StringName) -> void:
	if _sprite.visible and animation_name in BODY_CLIPS:
		_sprite.play(animation_name)
	# Animation completion deliberately never changes hitboxes, damage, state,
	# portal transitions or actor lifetime; gameplay remains authoritative.
