extends Node2D

## Optional Chaser proof adapter. Attacks, collision and progress remain gameplay.
const CLIPS := [&"idle", &"move", &"tell", &"attack", &"hurt", &"death"]
var _sprite: AnimatedSprite2D
var _actor: CharacterBody2D
var _frames: SpriteFrames
var _hurt_remaining := 0.0
var _tell_seconds := 0.25

func _ready() -> void:
	_actor = get_parent()
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "EnemySprite"
	_sprite.scale = Vector2(0.5,0.5)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	_actor.get_node("Health").damaged.connect(func(_n: int, _h: int): _hurt_remaining = 0.10)
	_actor.attack_tell_started.connect(func(_kind: String, seconds: float): _tell_seconds = seconds)

func apply_frames(candidate: SpriteFrames) -> bool:
	if candidate == null:
		return false
	for clip in CLIPS:
		if not candidate.has_animation(clip) or candidate.get_frame_count(clip) == 0 or candidate.get_animation_speed(clip) <= 0.0:
			return false
		if clip not in [&"idle", &"move"] and candidate.get_animation_loop(clip):
			return false
		for i in range(candidate.get_frame_count(clip)):
			var tex := candidate.get_frame_texture(clip,i)
			if tex == null or tex.get_size() != Vector2(256,256):
				return false
	_frames = candidate
	_sprite.sprite_frames = candidate
	_sprite.visible = true
	_actor.get_node("Visual").visible = false
	_sprite.play(&"idle")
	return true

func _duration(clip: StringName) -> float:
	if _frames == null:
		return 0.0
	var seconds := 0.0
	for i in range(_frames.get_frame_count(clip)):
		seconds += _frames.get_frame_duration(clip,i) / _frames.get_animation_speed(clip)
	return seconds

func death_presentation_seconds() -> float:
	return clampf(_duration(&"death"),0.0,1.0)

func _process(delta: float) -> void:
	if _frames == null:
		return
	_hurt_remaining = maxf(0.0,_hurt_remaining-delta)
	var clip: StringName = &"idle"
	# Keep as Variant until validity check: the actor may retain a freed attack
	# reference after recovery; assigning it to a typed Node already raises.
	var attack = _actor._attack
	if _actor.get_node("Health").dead:
		clip = &"death"
	elif is_instance_valid(attack) and not attack.is_queued_for_deletion() and attack.phase in [&"tell",&"active"]:
		clip = &"tell" if attack.phase == &"tell" else &"attack"
		_sprite.flip_h = attack.direction.x > 0.0
	elif _hurt_remaining > 0.0:
		clip = &"hurt"
	elif absf(_actor.velocity.x)>1.0:
		clip = &"move"
		_sprite.flip_h = _actor.velocity.x>0.0 # source faces left
	if _sprite.animation != clip:
		_sprite.play(clip)
	_sprite.speed_scale = _duration(&"tell") / maxf(0.05,_tell_seconds) if clip == &"tell" else 1.0
	# Presentation follows actual tell/active phases. Hurt cannot hide an active
	# danger phase, and no animation signal starts damage or removes the actor.
