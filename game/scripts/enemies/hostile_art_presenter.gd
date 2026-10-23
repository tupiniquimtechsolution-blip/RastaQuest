extends Node2D

## Optional reviewed-role adapter. No scene assigns an authoring texture by default.
var _actor: CharacterBody2D
var _sprite: AnimatedSprite2D
var _frames: SpriteFrames
var _patterns: Dictionary = {}
var _hurt := 0.0
var _tell := .25
var _active_elapsed := 0.0
var _last_attack_id := 0
var _equipment: Node2D
var _equipment_keys: Dictionary = {}
var _release_kinds := ["ranged","controller","chain_burst","portal_burst","fracture_storm"]

func _ready() -> void:
	_actor = get_parent()
	_sprite = AnimatedSprite2D.new()
	_sprite.name = "HostileSprite"
	_sprite.scale = Vector2(.5,.5)
	_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_sprite.visible = false
	add_child(_sprite)
	_sprite.frame_changed.connect(_sync_equipment)
	_actor.get_node("Health").damaged.connect(func(_n, _h): _hurt = .10)
	_actor.attack_tell_started.connect(func(_kind, seconds): _tell = seconds)

func apply_frames(candidate: SpriteFrames, patterns: Dictionary, source_size: int) -> bool:
	if candidate == null or source_size not in [256,512] or patterns.is_empty():
		return false
	var required: Array = [&"idle",&"move",&"hurt",&"death"]
	for pair in patterns.values():
		if not pair is Array or pair.size()!=2:
			return false
		for clip in pair:
			if not (clip is String or clip is StringName):
				return false
			required.append(StringName(clip))
	for clip in required:
		if not candidate.has_animation(clip) or candidate.get_frame_count(clip)<1 or candidate.get_animation_speed(clip)<=0.0:
			return false
		if clip not in [&"idle",&"move"] and candidate.get_animation_loop(clip):
			return false
		for i in range(candidate.get_frame_count(clip)):
			var texture := candidate.get_frame_texture(clip,i)
			if texture == null or texture.get_size()!=Vector2(source_size,source_size):
				return false
	_frames = candidate
	if is_instance_valid(_equipment):
		_equipment.free()
	_equipment_keys = {}
	_patterns = patterns.duplicate(true)
	_sprite.sprite_frames = candidate
	_sprite.visible = true
	_actor.get_node("Visual").visible = false
	_sprite.play(&"idle")
	return true

func apply_equipment(item: Texture2D, grip: Array, keys: Dictionary) -> bool:
	if _frames==null or item==null or grip.size()!=2 or item.get_width()>128 or item.get_height()>128:
		return false
	for number in grip:
		if not (number is float or number is int) or not is_finite(float(number)):
			return false
	for clip in _frames.get_animation_names():
		if clip=="default":
			continue
		if not keys.has(clip) or not keys[clip] is Array or keys[clip].size()!=_frames.get_frame_count(clip):
			return false
		for key in keys[clip]:
			if not key is Dictionary or not key.get("position") is Array or key.position.size()!=2:
				return false
			for value in key.position+[key.get("degrees")]:
				if not (value is int or value is float) or not is_finite(float(value)) or absf(float(value))>360:
					return false
	if is_instance_valid(_equipment):
		_equipment.free()
	_equipment_keys = keys.duplicate(true)
	_equipment = Node2D.new()
	_equipment.name = "RigidEquipment"
	_equipment.show_behind_parent = true
	_sprite.add_child(_equipment)
	var part := Sprite2D.new()
	part.name = "Item"
	part.texture = item
	part.centered = false
	part.offset = -Vector2(grip[0],grip[1])
	part.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_equipment.add_child(part)
	_sync_equipment()
	return true

func _sync_equipment() -> void:
	if not is_instance_valid(_equipment) or not _equipment_keys.has(String(_sprite.animation)):
		return
	var key: Dictionary = _equipment_keys[String(_sprite.animation)][_sprite.frame]
	_equipment.scale.x = -1 if _sprite.flip_h else 1
	var part: Sprite2D = _equipment.get_node("Item")
	part.position = Vector2(key.position[0],key.position[1])
	part.rotation_degrees = key.degrees

func _duration(clip: StringName) -> float:
	if _frames==null:
		return 0.0
	var seconds := 0.0
	for i in range(_frames.get_frame_count(clip)):
		seconds += _frames.get_frame_duration(clip,i)/_frames.get_animation_speed(clip)
	return seconds

func death_presentation_seconds() -> float:
	return clampf(_duration(&"death"),0,1)

func _process(delta: float) -> void:
	if _frames==null:
		return
	_hurt = maxf(0,_hurt-delta)
	var clip: StringName = &"idle"
	var attack = _actor._attack # Keep freed references Variant until validity check.
	var active: bool = is_instance_valid(attack) and not attack.is_queued_for_deletion()
	if active and attack.phase==&"active":
		var id: int = attack.get_instance_id()
		if id!=_last_attack_id:
			_last_attack_id = id
			_active_elapsed = 0.0
		_active_elapsed += delta
	else:
		_active_elapsed = 0.0
	if _actor.get_node("Health").dead:
		clip = &"death"
	elif active and attack.phase in [&"tell",&"active"] and _patterns.has(String(attack.kind)):
		var pair: Array = _patterns[String(attack.kind)]
		if attack.phase==&"tell":
			clip = StringName(pair[0])
		elif String(attack.kind) not in _release_kinds or _active_elapsed<=.16:
			clip = StringName(pair[1])
		# Projectile/area lifetime remains active after the body release pose.
		# No animation event starts/stops damage, projectiles or attack leases.
		_sprite.flip_h = attack.direction.x>0
	elif _hurt>0:
		clip = &"hurt"
	elif absf(_actor.velocity.x)>1:
		clip = &"move"
		_sprite.flip_h = _actor.velocity.x>0
	if _sprite.animation!=clip:
		_sprite.play(clip)
	_sprite.speed_scale = _duration(clip)/maxf(.05,_tell) if active and attack.phase==&"tell" else 1.0
	if clip==&"move" and _actor.get("data")!=null:
		_sprite.speed_scale = clampf(absf(_actor.velocity.x)/maxf(1,_actor.data.move_speed),.25,2)
	_sync_equipment()
