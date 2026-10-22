extends Node2D

## Optional Chaser proof adapter. Attacks, collision and progress remain gameplay.
const CLIPS := [&"idle", &"move", &"tell", &"attack", &"hurt", &"death"]
var _sprite: AnimatedSprite2D
var _actor: CharacterBody2D
var _frames: SpriteFrames
var _hurt_remaining := 0.0
var _tell_seconds := 0.25
var _equipment: Node2D
var _equipment_keys: Dictionary = {}

func _ready() -> void:
	_actor = get_parent()
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "EnemySprite"
	_sprite.scale = Vector2(0.5,0.5)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	_sprite.frame_changed.connect(_sync_equipment)
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
	# A new valid body packet must not inherit hand keys from a previous rig.
	if is_instance_valid(_equipment):
		_equipment.free()
	_equipment_keys = {}
	_frames = candidate
	_sprite.sprite_frames = candidate
	_sprite.visible = true
	_actor.get_node("Visual").visible = false
	_sprite.play(&"idle")
	return true

## Optional rigid equipment, expressed in native source pixels about origin128.
## Validate the whole packet before attaching it. No gameplay authority here.
func apply_equipment(sword: Texture2D, shield: Texture2D, keys: Dictionary) -> bool:
	if _frames == null or sword == null or shield == null:
		return false
	if sword.get_size() != Vector2(56,16) or shield.get_size() != Vector2(32,52):
		return false
	for clip in CLIPS:
		if not keys.has(String(clip)) or not keys[String(clip)] is Array or keys[String(clip)].size() != _frames.get_frame_count(clip):
			return false
		for key in keys[String(clip)]:
			if not key is Dictionary:
				return false
			for item in ["sword", "shield"]:
				var point = key.get(item+"_position")
				var angle = key.get(item+"_degrees")
				if not point is Array or point.size() != 2 or not (angle is float or angle is int):
					return false
				for number in point:
					if not (number is float or number is int) or not is_finite(float(number)) or absf(float(number)) > 128.0:
						return false
				if not is_finite(float(angle)) or absf(float(angle)) > 360.0:
					return false
	if is_instance_valid(_equipment):
		_equipment.free()
	_equipment_keys = keys.duplicate(true)
	_equipment = Node2D.new()
	_equipment.name = "RigidEquipment"
	_sprite.add_child(_equipment)
	for item in [["sword",sword,Vector2(46,8)],["shield",shield,Vector2(16,26)]]:
		var part := Sprite2D.new()
		part.name = item[0]
		part.texture = item[1]
		part.centered = false
		part.offset = -item[2]
		part.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_equipment.add_child(part)
	_sync_equipment()
	return true

func _sync_equipment() -> void:
	if not is_instance_valid(_equipment) or not _equipment_keys.has(String(_sprite.animation)):
		return
	var key: Dictionary = _equipment_keys[String(_sprite.animation)][_sprite.frame]
	# AnimatedSprite.flip_h flips its texture only, not its child transforms.
	_equipment.scale.x = -1.0 if _sprite.flip_h else 1.0
	for item in ["sword", "shield"]:
		var part: Sprite2D = _equipment.get_node(item)
		var point: Array = key[item+"_position"]
		part.position = Vector2(point[0],point[1])
		part.rotation_degrees = key[item+"_degrees"]

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
	_sync_equipment()
	# Presentation follows actual tell/active phases. Hurt cannot hide an active
	# danger phase, and no animation signal starts damage or removes the actor.
