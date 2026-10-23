extends Area2D

signal portal_entered

@export var sprite_frames: SpriteFrames
var _sprite: AnimatedSprite2D
const MAX_ENTRY_SECONDS := 0.8

@onready var visual: Polygon2D = $Visual
var locked: bool = true

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_locked(true)
	if sprite_frames != null:
		apply_frames(sprite_frames)

func apply_frames(candidate: SpriteFrames) -> bool:
	if candidate == null:
		return false
	for clip in [&"idle", &"enter"]:
		if not candidate.has_animation(clip) or candidate.get_frame_count(clip) == 0 or candidate.get_animation_speed(clip) <= 0.0:
			return false
		if clip == &"enter" and candidate.get_animation_loop(clip):
			return false
		for index in range(candidate.get_frame_count(clip)):
			var tex := candidate.get_frame_texture(clip, index)
			if tex == null or tex.get_size() != Vector2(256, 256):
				return false
	if not is_instance_valid(_sprite):
		_sprite = AnimatedSprite2D.new()
		_sprite.name = "PortalSprite"
		_sprite.scale = Vector2(0.5, 0.5)
		_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(_sprite)
	sprite_frames = candidate
	_sprite.sprite_frames = candidate
	visual.visible = false
	_sprite.play(&"idle")
	set_locked(locked)
	return true

func start_entry_presentation() -> float:
	if not is_instance_valid(_sprite):
		return 0.0
	var seconds := 0.0
	for index in range(sprite_frames.get_frame_count(&"enter")):
		seconds += sprite_frames.get_frame_duration(&"enter", index) / sprite_frames.get_animation_speed(&"enter")
	if SettingsManager.reduced_flashes_enabled():
		_sprite.play(&"idle")
	else:
		_sprite.play(&"enter")
	return clampf(seconds, 0.0, MAX_ENTRY_SECONDS)

func cancel_entry_presentation() -> void:
	if is_instance_valid(_sprite):
		_sprite.play(&"idle")

func set_locked(value: bool) -> void:
	locked = value
	set_deferred("monitoring", not locked)
	visual.modulate = Color(0.45, 0.45, 0.45, 1.0) if locked else Color(1.0, 1.0, 1.0, 1.0)
	if is_instance_valid(_sprite):
		_sprite.modulate = visual.modulate

func _physics_process(_delta: float) -> void:
	if not locked and monitoring:
		for body in get_overlapping_bodies():
			if body.name == "Player" and body.can_attack():
				portal_entered.emit()

func _on_body_entered(body: Node2D) -> void:
	if locked:
		return
	if body.name == "Player":
		portal_entered.emit()
