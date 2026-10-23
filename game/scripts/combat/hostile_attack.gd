extends Node2D

const Budget = preload("res://scripts/combat/hostile_attack_budget.gd")
const HIGH_THREAT := ["charger", "controller", "exploder", "storm_slam", "chain_burst", "rift_slam", "portal_burst", "fracture_storm"]
const SHOTS := ["ranged", "chain_burst", "portal_burst"]

var phase: StringName = &"tell"
var kind: String = "chaser"
var direction := Vector2.RIGHT
var _actor: CharacterBody2D
var _target: Node2D
var _budget: Node
var _remaining: float = 0.0
var _active_seconds: float = 0.16
var _recovery_seconds: float = 0.30
var _centers: Array[Vector2] = []
var _velocities: Array[Vector2] = []
var _hit_targets: Dictionary = {}
var _shape: Shape2D
var _damage := 1
var _leased := false
var _art_elapsed := 0.0

func begin(actor: CharacterBody2D, target: Node2D, attack_kind: String, tell_seconds: float) -> bool:
	_actor = actor
	_target = target
	kind = attack_kind
	if not is_instance_valid(target) or not is_instance_valid(actor):
		return false
	var container := actor.get_parent()
	_budget = container.get_node_or_null("HostileAttackBudget")
	if _budget == null:
		_budget = Budget.new()
		_budget.name = "HostileAttackBudget"
		container.add_child(_budget)
	_leased = _budget.acquire(get_instance_id(), kind in HIGH_THREAT)
	if not _leased:
		return false
	_remaining = maxf(0.05, tell_seconds)
	direction = actor.global_position.direction_to(target.global_position)
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	_configure_shape()
	return true

func _configure_shape() -> void:
	var facing := 1.0 if direction.x >= 0.0 else -1.0
	if kind in SHOTS:
		var circle := CircleShape2D.new()
		circle.radius = 9.0
		_shape = circle
		_active_seconds = 1.8
		var angles: Array[float] = [0.0]
		if kind != "ranged":
			angles.assign([-0.25, 0.0, 0.25])
		for angle in angles:
			_centers.append(_actor.global_position + direction * 25.0)
			_velocities.append(direction.rotated(angle) * 420.0)
	elif kind in ["controller", "exploder", "storm_slam", "rift_slam", "fracture_storm"]:
		var circle := CircleShape2D.new()
		circle.radius = 58.0 if kind in ["controller", "fracture_storm"] else 110.0
		_shape = circle
		_active_seconds = 0.45 if kind == "controller" else 0.18
		var center := _actor.global_position
		if kind in ["controller", "fracture_storm"]:
			center += (_target.global_position - center).limit_length(300.0)
		_centers.append(center)
		if kind == "fracture_storm":
			_centers.append(center + Vector2(-125, 0))
			_centers.append(center + Vector2(125, 0))
	else:
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(75, 52) if kind == "charger" else Vector2(62, 52)
		_shape = rectangle
		_centers.append(_actor.global_position + Vector2(facing * 40.0, 0))
		_active_seconds = 0.35 if kind == "charger" else 0.16
	_damage = 2 if kind in ["exploder", "storm_slam", "rift_slam", "fracture_storm"] else 1

func movement_velocity() -> float:
	return signf(direction.x) * 650.0 if phase == &"active" and kind == "charger" else 0.0

func _physics_process(delta: float) -> void:
	if not _leased:
		return
	if not is_instance_valid(_actor) or _actor.is_queued_for_deletion() or _actor.get_node("Health").dead:
		cancel()
		return
	_remaining -= delta
	_art_elapsed += delta
	if phase == &"tell" and _remaining <= 0.0:
		phase = &"active"
		_remaining = _active_seconds
	if phase == &"active":
		if kind in ["chaser", "charger"]:
			_centers[0] = _actor.global_position + Vector2(signf(direction.x) * 40.0, 0)
		for index in range(_centers.size()):
			if kind in SHOTS:
				var next := _centers[index] + _velocities[index] * delta
				if _blocked(_centers[index], next):
					_velocities[index] = Vector2.ZERO
					continue
				if _velocities[index].is_zero_approx():
					continue
				_centers[index] = next
			_apply_hits(_centers[index])
		if _remaining <= 0.0:
			phase = &"recovery"
			_remaining = _recovery_seconds
			if kind == "exploder":
				var health: Node = _actor.get_node("Health")
				health.take_damage(health.max_health, true)
	if phase == &"recovery" and _remaining <= 0.0:
		cancel()
	queue_redraw()

func _body_exclusions() -> Array[RID]:
	var excluded: Array[RID] = []
	for actor in get_tree().get_nodes_in_group("hostile_actor"):
		if actor is CollisionObject2D:
			excluded.append(actor.get_rid())
	if _target is CollisionObject2D:
		excluded.append(_target.get_rid())
	return excluded

func _blocked(from: Vector2, to: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(from, to, 1, _body_exclusions())
	return not get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _apply_hits(center: Vector2) -> void:
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = _shape
	query.transform = Transform2D(0.0, center)
	query.collision_mask = 2
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for contact in get_world_2d().direct_space_state.intersect_shape(query, 8):
		var hurtbox: Area2D = contact["collider"] as Area2D
		if hurtbox == null or not hurtbox.has_method("receive_hit") or _hit_targets.has(hurtbox.get_instance_id()):
			continue
		if _blocked(center, hurtbox.global_position):
			continue
		_hit_targets[hurtbox.get_instance_id()] = true
		hurtbox.receive_hit({"attack_id": get_instance_id(), "amount": _damage, "damage_type": StringName(kind), "source": _actor.get_instance_id()})

func cancel() -> void:
	phase = &"cancelled"
	set_physics_process(false)
	_release()
	queue_free()

func _release() -> void:
	if _leased and is_instance_valid(_budget):
		_budget.release(get_instance_id())
	_leased = false

func _exit_tree() -> void:
	_release()

func _draw() -> void:
	if not _leased or phase == &"recovery":
		return
	# Debug geometry communicates real attack timing; it is not final production art.
	var color := Color(1.0, 0.55, 0.15, 0.75) if phase == &"tell" else Color(0.95, 0.15, 0.15, 0.85)
	for index in range(_centers.size()):
		if kind in SHOTS and phase == &"active" and _velocities[index].is_zero_approx():
			continue
		var point := to_local(_centers[index])
		var key := "hostile_projectile" if kind in SHOTS else "hostile_area"
		var catalog := get_node_or_null("/root/ArtCatalog")
		var tex: Texture2D = catalog.effect_frame(key,_art_elapsed,.24) if catalog!=null else null
		if tex!=null:
			var size: Vector2 = Vector2.ONE*_shape.radius*2 if _shape is CircleShape2D else _shape.size
			# Match the actual danger footprint; thin precise outlines below remain
			# authoritative for radius/extent, even with reduced/static effects.
			draw_texture_rect(tex,Rect2(point-size*.5,size),false,Color(1,1,1,.5 if phase==&"tell" else .8))
		if _shape is CircleShape2D:
			draw_circle(point, _shape.radius, color, false, 3.0)
		elif _shape is RectangleShape2D:
			draw_rect(Rect2(point - _shape.size * 0.5, _shape.size), color, false, 3.0)
