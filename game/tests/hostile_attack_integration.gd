extends SceneTree

const Enemy = preload("res://scenes/enemies/EnemyBase.tscn")
const Player = preload("res://scenes/player/Player.tscn")
const Rift = preload("res://scenes/boss/RiftSovereign.tscn")
const Warden = preload("res://scenes/boss/StormWarden.tscn")

func _init() -> void:
	call_deferred("_run")

func _pair(behavior: String, distance: float, boss_scene: PackedScene = null) -> Dictionary:
	var world := Node2D.new()
	root.add_child(world)
	var player := Player.instantiate()
	player.name = "Player"
	player.position = Vector2(100 + distance, 100)
	world.add_child(player)
	player.set_physics_process(false)
	var health: Node = player.get_node("Health")
	health.max_health = 100
	health.invulnerability_seconds = 0.0
	health.reset_health()
	var enemy: CharacterBody2D
	if boss_scene == null:
		enemy = Enemy.instantiate()
		enemy.data = load("res://data/enemies/%s.tres" % behavior).duplicate()
		enemy.data.move_speed = 0.0
		enemy.data.tell_seconds = 0.10
		enemy.data.attack_cooldown = 100.0
	else:
		enemy = boss_scene.instantiate()
	enemy.position = Vector2(100, 100)
	enemy.target_path = NodePath("../Player")
	world.add_child(enemy)
	enemy.set_physics_process(false)
	return {"world": world, "player": player, "enemy": enemy, "health": health}

func _advance(pair: Dictionary, frames: int) -> void:
	for _i in range(frames):
		if is_instance_valid(pair.enemy) and not pair.enemy.is_queued_for_deletion():
			pair.enemy._physics_process(0.0)
		await physics_frame
		await process_frame

func _discard(pair: Dictionary) -> void:
	pair.world.queue_free()
	await process_frame

func _run() -> void:
	print("HOSTILE_TEST userdata=", OS.get_user_data_dir())
	for behavior in ["chaser", "ranged", "charger", "controller", "exploder"]:
		var distance := 220.0 if behavior == "ranged" else 45.0
		var pair := _pair(behavior, distance)
		await _advance(pair, 55)
		var expected := 98 if behavior == "exploder" else 99
		if pair.health.health != expected:
			_fail("%s must deal exactly one hit, got health %s" % [behavior, pair.health.health])
			return
		if behavior == "charger" and pair.enemy.position.x <= 100.0:
			_fail("charger did not move during active attack")
			return
		await _discard(pair)

	# The same melee attack cannot follow a player who dodges after its tell.
	var dodge := _pair("chaser", 45.0)
	await _advance(dodge, 2)
	dodge.player.position.x = 900.0
	await _advance(dodge, 35)
	if dodge.health.health != 100:
		_fail("melee hit a player outside its active shape")
		return
	await _discard(dodge)

	# Real projectile movement must stop at level geometry.
	var wall_test := _pair("ranged", 220.0)
	var wall := StaticBody2D.new()
	wall.position = Vector2(210, 100)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(12, 180)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	wall_test.world.add_child(wall)
	await _advance(wall_test, 55)
	if wall_test.health.health != 100:
		_fail("projectile crossed a wall")
		return
	await _discard(wall_test)

	# Death cancels both a pending tell and an already launched projectile.
	for kind in ["chaser", "ranged"]:
		var cancel_test := _pair(kind, 45.0 if kind == "chaser" else 300.0)
		if kind == "chaser":
			cancel_test.enemy.data.tell_seconds = 1.0
		await _advance(cancel_test, 2 if kind == "chaser" else 12)
		cancel_test.enemy.get_node("Health").take_damage(1000, true)
		await _advance(cancel_test, 70)
		if cancel_test.health.health != 100 or cancel_test.world.get_node("HostileAttackBudget").active_count() != 0:
			_fail("death left a delayed hit or leaked attack lease: %s" % kind)
			return
		await _discard(cancel_test)

	# Cap real simultaneous high-threat attacks; death must release a lease.
	var capped := _pair("controller", 45.0)
	capped.enemy.data.tell_seconds = 2.0
	capped.enemy._physics_process(0.0)
	var extra: Array[Node] = []
	for _i in range(2):
		var actor := Enemy.instantiate()
		actor.data = capped.enemy.data.duplicate()
		actor.target_path = NodePath("../Player")
		actor.position = Vector2(100, 100)
		capped.world.add_child(actor)
		actor.set_physics_process(false)
		actor._physics_process(0.0)
		extra.append(actor)
	var budget: Node = capped.world.get_node("HostileAttackBudget")
	if budget.high_threat_count() != 2 or is_instance_valid(extra[1]._attack):
		_fail("third high-threat attack bypassed the live cap")
		return
	capped.enemy.get_node("Health").take_damage(1000, true)
	extra[1]._physics_process(0.0)
	if budget.high_threat_count() != 2 or not is_instance_valid(extra[1]._attack):
		_fail("cancelled high-threat lease was not reusable")
		return
	await _discard(capped)

	# Two overlapping independent attacks still respect player invulnerability.
	var protected := _pair("chaser", 45.0)
	protected.health.invulnerability_seconds = 1.0
	var second := Enemy.instantiate()
	second.data = protected.enemy.data.duplicate()
	second.target_path = NodePath("../Player")
	second.position = Vector2(100, 100)
	protected.world.add_child(second)
	second.set_physics_process(false)
	second._physics_process(0.0)
	await _advance(protected, 25)
	if protected.health.health != 99:
		_fail("overlapping independent attacks bypassed player invulnerability")
		return
	await _discard(protected)

	# Both boss scenes execute each phase through the same real damage path.
	for boss_scene in [Warden, Rift]:
		var ratios: Array[float] = [1.0, 0.4]
		if boss_scene == Rift:
			ratios.assign([1.0, 0.5, 0.2])
		for ratio in ratios:
			var boss := _pair("", 65.0, boss_scene)
			var boss_health: Node = boss.enemy.get_node("Health")
			boss_health.health = maxi(1, int(boss_health.max_health * ratio))
			await _advance(boss, 75)
			if boss.health.health >= 100:
				_fail("boss phase produced a tell without player damage: %s/%s" % [boss_scene.resource_path, ratio])
				return
			await _discard(boss)

	# A player hit must reach the final boss's health through its scene hurtbox.
	var victory := _pair("", 65.0, Rift)
	victory.enemy.set_physics_process(false)
	var hitbox: Area2D = victory.player.get_node("AttackHitbox")
	hitbox.position = Vector2(-38, 0)
	await physics_frame
	hitbox.begin_attack(42, 2, &"axe")
	for _i in range(4):
		await physics_frame
		await process_frame
	if victory.enemy.get_node("Health").health != 18:
		_fail("player axe did not damage final boss through its hurtbox")
		return
	hitbox.end_attack()
	await _discard(victory)
	print("RQ_HOSTILE_ATTACK_INTEGRATION_OK archetypes=5 boss_phases=5 cap=2 cancellation=pass")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
