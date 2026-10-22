extends SceneTree

const Art = preload("res://tests/art_review_fixtures.gd")

func _init() -> void:
	call_deferred("_run")

func _prepare(room: Node) -> void:
	room._clear_enemies()
	room._alive_enemies = 0
	room.portal.set_locked(false)

func _run() -> void:
	var save: Node = root.get_node("SaveManager")
	var run: Node = root.get_node("RunManager")
	var settings: Node = root.get_node("SettingsManager")
	save.configure_paths("user://rq_portal_drop.json", "user://rq_portal_drop.bak.json")
	save.data = save.default_data()
	save.set_completion_flag(&"tutorial_complete", true)
	settings.reload_from_save()
	run.start_run(424242)
	run.state.depth = 2
	var scene: PackedScene = load("res://scenes/world/RunPrototypeRoom.tscn")
	var room := scene.instantiate()
	root.add_child(room)
	current_scene = room
	_prepare(room)
	var player: CharacterBody2D = room.player
	player.position.y = 614.0
	var visual: Node2D = player.get_node("Visual")
	var health: Node = player.get_node("Health")
	var combat: Node = player.get_node("PlayerCombat")
	if not Art.assign(player, room.portal) or not combat.try_attack():
		_fail("review textures or initial attack failed")
		return
	room._on_portal_entered()
	room._on_portal_entered()
	if player.current_animation_name() != &"portal_enter" or combat.try_attack() or player.get_node("AttackHitbox")._active:
		_fail("portal must latch once and cancel/block attacks")
		return
	await create_timer(0.1).timeout
	health.take_damage(1, true)
	if room._portal_transitioning or player.is_entering_portal() or not is_equal_approx(visual.get_node("ProductionSprite").modulate.a, 1.0):
		_fail("damage did not cancel presentation and restore actor opacity")
		return
	await create_timer(0.2).timeout
	room._on_portal_entered()
	# Old cancelled entry expires during this new one. Its token cannot commit it.
	await create_timer(0.14).timeout
	if room.reward_panel.visible or run.state.depth != 2 or not player.is_entering_portal():
		_fail("stale timer advanced the replacement portal entry")
		return
	await create_timer(0.25).timeout
	if not room.reward_panel.visible or room._pending_choices.size() == 0:
		_fail("completed portal failed to show a single upgrade choice")
		return
	room._on_upgrade_selected(0)
	room._on_upgrade_selected(0)
	if run.state.depth != 3 or player.is_entering_portal() or not is_equal_approx(visual.get_node("ProductionSprite").modulate.a, 1.0):
		_fail("double selection advanced twice or respawn retained fade/input lock")
		return
	_prepare(room)
	settings.set_value(&"reduced_flashes", true)
	room._on_portal_entered()
	if room.portal.get_node("PortalSprite").animation != &"idle":
		_fail("reduced flashes must keep a static portal rim")
		return
	await create_timer(0.4).timeout
	room._on_upgrade_selected(0)
	_prepare(room)
	# Mirrored fatal entry proves death takes precedence over pending rewards.
	player.velocity.x = -20.0
	player._update_facing()
	room._on_portal_entered()
	await create_timer(0.08).timeout
	health.take_damage(1000, true)
	await create_timer(0.32).timeout
	var dropped: Sprite2D = visual.get_node_or_null("DroppedWeapon")
	if dropped == null or dropped.texture != visual.dropped_weapon_texture or dropped.scale != Vector2(0.5, 0.5) or dropped.global_transform.x.x >= 0.0:
		_fail("independent rigid death layer or mirrored density failed")
		return
	var bottom := dropped.global_transform * Vector2(0.0, dropped.texture.get_image().get_used_rect().end.y - 128.0)
	if absf(bottom.y - 640.0) > 1.0 or room.reward_panel.visible or save.completion_flag(&"campaign_complete"):
		_fail("fallen axe did not contact floor or dead portal granted progression")
		return
	if dropped.get_child_count() != 0:
		_fail("decorative fallen axe must not carry damage or collision")
		return
	if dropped.z_index < 0 or dropped.get_index() > visual.get_node("ProductionSprite").get_index():
		_fail("fallen weapon must draw above backdrop and behind the body")
		return
	await create_timer(0.4).timeout
	if current_scene.scene_file_path != "res://scenes/hub/Hub.tscn":
		_fail("death lost its bounded return after interrupting portal entry")
		return
	print("RQ_PORTAL_DROP_OK stale_timer=cancelled input_damage=locked reduced_flashes=static rigid_drop=mirrored_floor640 death=priority")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
