extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _run() -> void:
	var save: Node = root.get_node("SaveManager")
	save.configure_paths("user://rq_forest_proof.json","user://rq_forest_proof.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete",true)
	root.get_node("RunManager").start_run(424242)
	var scene: PackedScene = load("res://scenes/world/RunPrototypeRoom.tscn")
	var room := scene.instantiate()
	root.add_child(room)
	room._clear_enemies()
	var art: Script = load("res://tests/art_review_fixtures.gd")
	art.assign(room.player,room.portal)
	var fixture: Script = load("res://tests/forest_review_fixture.gd")
	var enemy: CharacterBody2D = fixture.build(room)
	enemy.position = Vector2(685,611)
	room.player.position = Vector2(640,614)
	var shape_size: Vector2 = enemy.get_node("CollisionShape2D").shape.size
	var sprite: AnimatedSprite2D = enemy.get_node("SpritePresenter/EnemySprite")
	var seen := {}
	for _i in range(50):
		await physics_frame
		await process_frame
		seen[sprite.animation] = true
	if not seen.has(&"tell") or not seen.has(&"attack") or room.player.get_node("Health").health >= 5:
		_fail("Chaser actual phases/art did not deliver its real hit")
		return
	if sprite.scale != Vector2(0.5,0.5) or shape_size != Vector2(34,58):
		_fail("Chaser presentation changed source scale or collider")
		return
	var before: int = room.player.get_node("Health").health
	enemy.get_node("Health").take_damage(1000,true)
	await create_timer(0.1).timeout
	if not is_instance_valid(enemy) or sprite.animation != &"death" or room._alive_enemies != 0 or room.get_node("Enemies/HostileAttackBudget").active_count() != 0:
		_fail("enemy death must cancel damage/progress once while keeping decorative pose")
		return
	await create_timer(0.3).timeout
	if is_instance_valid(enemy) or room.player.get_node("Health").health != before or room.portal.locked:
		_fail("Chaser death timer leaked damage, blocked portal or failed cleanup")
		return
	for landing in [Vector2(448,576),Vector2(896,512)]:
		room.player.position = Vector2(landing.x,landing.y-60)
		room.player.velocity = Vector2.ZERO
		for _i in range(30):
			await physics_frame
		if not room.player.is_on_floor() or absf(room.player.position.y+26.0-landing.y)>1.0:
			_fail("review platform top differs from its painted tile boundary")
			return
	print("RQ_FOREST_CHASER_OK floor640=unchanged collider34x58=unchanged clips6=actual_phases damage=real death=cancelled")
	room.queue_free()
	await process_frame
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
