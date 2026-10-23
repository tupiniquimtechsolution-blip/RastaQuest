extends Node2D

## Returned projectile is a physical, bounded shot; it never teleports damage.
var target: Node2D
var defender: Node2D
var amount := 1.0
var speed := 600.0
var remaining := 1.5
var elapsed := 0.0
var _trail: Array[Vector2] = []
var _shape := CircleShape2D.new()

func _ready() -> void:
	_shape.radius = 9.0
	add_to_group("reflected_projectile")

func _physics_process(delta: float) -> void:
	remaining -= delta
	elapsed += delta
	if remaining<=0.0 or not is_instance_valid(target) or target.is_queued_for_deletion() or target.get_node("Health").dead or not is_instance_valid(defender) or defender.get_node("Health").dead:
		queue_free()
		return
	if get_node("/root/SettingsManager").reduced_flashes_enabled():
		_trail.clear()
	else:
		_trail.append(global_position)
		if _trail.size()>4:
			_trail.pop_front()
	var travel := global_position.direction_to(target.global_position)*speed*delta
	var steps := clampi(ceili(travel.length()/8.0),1,64)
	var excluded: Array[RID] = []
	for actor in get_tree().get_nodes_in_group("hostile_actor"):
		if actor is CollisionObject2D:
			excluded.append(actor.get_rid())
	if defender is CollisionObject2D:
		excluded.append(defender.get_rid())
	for _i in range(steps):
		var next := global_position+travel/steps
		var wall := PhysicsRayQueryParameters2D.create(global_position,next,1,excluded)
		if not get_world_2d().direct_space_state.intersect_ray(wall).is_empty():
			queue_free()
			return
		global_position = next
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = _shape
		query.transform = Transform2D(0,global_position)
		query.collision_mask = 4
		query.collide_with_areas = true
		query.collide_with_bodies = false
		for contact in get_world_2d().direct_space_state.intersect_shape(query,16):
			var hurtbox: Area2D = contact.collider
			if hurtbox.get_parent()!=target:
				continue
			var accepted: bool = hurtbox.receive_hit({"amount":amount,"damage_type":&"reflected","source":defender.get_instance_id(),"attack_id":get_instance_id()})
			if accepted:
				get_node("/root/ArtCatalog").burst("hit",global_position,self,40,.16)
			queue_free()
			return
	queue_redraw()

func _draw() -> void:
	if not get_node("/root/SettingsManager").reduced_flashes_enabled() and _trail.size()>1:
		var points := PackedVector2Array()
		for point in _trail:
			points.append(to_local(point))
		points.append(Vector2.ZERO)
		draw_polyline(points,Color(.35,.85,1,.28),2.0,true)
	var texture: Texture2D = get_node("/root/ArtCatalog").effect_frame("hostile_projectile",elapsed,.24)
	if texture!=null:
		var region: Rect2 = get_node("/root/ArtCatalog").effect_region(texture)
		draw_texture_rect_region(texture,Rect2(-Vector2.ONE*9,Vector2.ONE*18),region,Color(.65,1,1,.85))
		return
	draw_circle(Vector2.ZERO,8,Color(.35,.85,1,.65))
	draw_arc(Vector2.ZERO,9,0,TAU,24,Color(.7,1,1,.85),2,true)
