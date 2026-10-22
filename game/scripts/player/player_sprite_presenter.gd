extends Node2D

## Optional production art adapter. Never manufactures frames or changes combat.
const BODY_CLIPS := [&"idle", &"run", &"jump", &"fall", &"attack_axe", &"attack_axe_air", &"hurt", &"death"]
const SOURCE_FRAME := Vector2(256, 256)
const VISUAL_SCALE := Vector2(0.5, 0.5)
const MAX_DEATH_PRESENTATION_SECONDS := 1.5

@export var sprite_frames: SpriteFrames
## Frame-aligned independent layer, not a concept sheet or a gameplay collider.
@export var dropped_weapon_texture: Texture2D
var _sprite: AnimatedSprite2D
var _player: Node
var _dropped: Sprite2D
var _drop_tween: Tween
var _portal_tween: Tween

func _ready() -> void:
	_player = get_parent()
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "ProductionSprite"
	_sprite.centered = true
	_sprite.scale = VISUAL_SCALE
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	_sprite.frame_changed.connect(_on_frame_changed)
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
	if animation_name != &"portal_enter":
		if _portal_tween != null:
			_portal_tween.kill()
		_sprite.modulate.a = 1.0
		_sprite.position = Vector2.ZERO
	if animation_name != &"death":
		_clear_dropped_weapon()
	if _sprite.visible and animation_name in BODY_CLIPS:
		_sprite.play(animation_name)
	# Animation completion deliberately never changes hitboxes, damage, state,
	# portal transitions or actor lifetime; gameplay remains authoritative.

func begin_portal_presentation(seconds: float) -> void:
	if not _sprite.visible or seconds <= 0.0:
		return
	if _portal_tween != null:
		_portal_tween.kill()
	_sprite.play(&"idle")
	_portal_tween = create_tween().set_parallel(true)
	_portal_tween.tween_property(_sprite, "modulate:a", 0.0, minf(seconds, 0.8))
	_portal_tween.tween_property(_sprite, "position:x", 6.0, minf(seconds, 0.8))
	# A quiet presentation rig using the approved body, not four new drawn poses.
	# Completion never advances rooms or grants rewards.

func _on_frame_changed() -> void:
	if not _sprite.visible or _sprite.animation != &"death" or _sprite.frame < 1:
		return
	if is_instance_valid(_dropped) or dropped_weapon_texture == null:
		return
	if dropped_weapon_texture.get_size() != SOURCE_FRAME:
		return
	var used := dropped_weapon_texture.get_image().get_used_rect()
	if used.size == Vector2i.ZERO:
		return
	_dropped = Sprite2D.new()
	_dropped.name = "DroppedWeapon"
	_dropped.texture = dropped_weapon_texture
	_dropped.scale = VISUAL_SCALE
	_dropped.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(_dropped)
	# Sibling order keeps it behind the body without putting it behind the
	# room's backdrop/ground (a negative global z would hide the whole prop).
	move_child(_dropped, 0)
	# Keep the same frame origin/facing. Raycast the visible bottom against level
	# geometry; the fallen prop has no hitbox or collision and may sit behind body.
	var bottom := _dropped.global_transform * Vector2(0.0, used.end.y - 128.0)
	var query := PhysicsRayQueryParameters2D.create(bottom, bottom + Vector2(0.0, 2000.0), 1)
	query.exclude = [_player.get_rid()]
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var distance := maxf(0.0, float(hit.position.y) - bottom.y)
		_drop_tween = create_tween()
		_drop_tween.tween_property(_dropped, "global_position:y", _dropped.global_position.y + distance, 0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _clear_dropped_weapon() -> void:
	if _drop_tween != null:
		_drop_tween.kill()
	if is_instance_valid(_dropped):
		_dropped.queue_free()
		_dropped = null
