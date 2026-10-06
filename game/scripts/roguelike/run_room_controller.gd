extends Node2D

const EnemyScene = preload("res://scenes/enemies/EnemyBase.tscn")
const BossScene = preload("res://scenes/boss/StormWarden.tscn")
const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")

const BOSS_DEPTH: int = 5
const ENEMY_DATA := {
	"chaser": preload("res://data/enemies/chaser.tres"),
	"ranged": preload("res://data/enemies/ranged.tres"),
	"charger": preload("res://data/enemies/charger.tres"),
	"controller": preload("res://data/enemies/controller.tres"),
	"exploder": preload("res://data/enemies/exploder.tres"),
}

@onready var player: CharacterBody2D = $Player
@onready var portal: Area2D = $Portal
@onready var backdrop: Polygon2D = $Backdrop
@onready var reward_panel: Control = $Hud/RewardPanel
@onready var reward_buttons: Array[Button] = [
	$Hud/RewardPanel/VBox/Choice1,
	$Hud/RewardPanel/VBox/Choice2,
	$Hud/RewardPanel/VBox/Choice3,
]
@onready var status_label: Label = $Hud/Status

var _alive_enemies: int = 0
var _pending_choices: Array = []
var _forest_rooms: Array = []
var _boss_active: bool = false

func _ready() -> void:
	portal.portal_entered.connect(_on_portal_entered)
	player.get_node("Health").died.connect(_on_player_died)
	for index in range(reward_buttons.size()):
		reward_buttons[index].pressed.connect(_on_upgrade_selected.bind(index))

	_forest_rooms = RoomCatalog.load_forest()
	if not RunManager.state.run_active:
		RunManager.start_run(424242)

	_apply_run_modifiers()
	_start_encounter()

func _start_encounter() -> void:
	reward_panel.visible = false
	portal.set_locked(true)
	_clear_enemies()

	if RunManager.state.depth >= BOSS_DEPTH:
		_start_boss()
		return

	_boss_active = false
	var room_id := RunManager.state.choose_room(RoomCatalog.ids(_forest_rooms))
	var room: RoomTemplateData = RoomCatalog.by_id(_forest_rooms, room_id)
	if room == null:
		status_label.text = "Invalid room template"
		return

	backdrop.color = room.background_color
	_alive_enemies = room.enemy_archetypes.size()

	for index in range(room.enemy_archetypes.size()):
		var enemy := EnemyScene.instantiate()
		var behavior := room.enemy_archetypes[index]
		enemy.data = ENEMY_DATA.get(behavior, ENEMY_DATA["chaser"])
		enemy.target_path = NodePath("../../Player")
		enemy.position = room.spawn_positions[index] if index < room.spawn_positions.size() else Vector2(600 + index * 140, 610)
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		$Enemies.add_child(enemy)

	status_label.text = "%s • Seed %d • Encounter %d" % [room.title, RunManager.state.seed_value, RunManager.state.depth + 1]

func _start_boss() -> void:
	_boss_active = true
	_alive_enemies = 1
	backdrop.color = Color(0.07, 0.04, 0.10, 1.0)
	var boss := BossScene.instantiate()
	boss.position = Vector2(850, 585)
	boss.boss_defeated.connect(_on_boss_defeated)
	$Enemies.add_child(boss)
	status_label.text = "Storm Warden • Forest guardian"

func _clear_enemies() -> void:
	for child in $Enemies.get_children():
		child.queue_free()

func _on_enemy_defeated(_enemy: Node) -> void:
	_alive_enemies = maxi(_alive_enemies - 1, 0)
	if _alive_enemies == 0:
		portal.set_locked(false)
		status_label.text = "Encounter clear • Enter the portal"

func _on_boss_defeated() -> void:
	_alive_enemies = 0
	portal.set_locked(false)
	status_label.text = "Storm Warden defeated • Exit through the portal"

func _on_portal_entered() -> void:
	portal.set_locked(true)

	if _boss_active:
		SaveManager.add_meta_shards(5)
		SaveManager.set_completion_flag(&"forest_vertical_slice_complete", true)
		RunManager.end_run()
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
		return

	_pending_choices = RunManager.sample_upgrade_choices(3)
	if _pending_choices.is_empty():
		RunManager.advance_encounter()
		player.respawn()
		_start_encounter()
		return

	reward_panel.visible = true
	for index in range(reward_buttons.size()):
		var button := reward_buttons[index]
		if index < _pending_choices.size():
			var upgrade: UpgradeData = _pending_choices[index]
			button.visible = true
			button.text = "%s\n%s" % [upgrade.title, upgrade.description]
		else:
			button.visible = false

func _on_upgrade_selected(index: int) -> void:
	if index < 0 or index >= _pending_choices.size():
		return
	var upgrade: UpgradeData = _pending_choices[index]
	RunManager.apply_upgrade(upgrade)
	RunManager.advance_encounter()
	_apply_run_modifiers()
	player.respawn()
	_start_encounter()

func _on_player_died() -> void:
	SaveManager.add_meta_shards(maxi(1, RunManager.state.depth))
	RunManager.end_run()
	call_deferred("_return_to_hub")

func _return_to_hub() -> void:
	get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")

func _apply_run_modifiers() -> void:
	var mods: Dictionary = RunManager.state.modifiers
	var combat: Node = player.get_node("PlayerCombat")
	var health: Node = player.get_node("Health")

	player.move_speed = 260.0 + float(mods[&"move_speed"])
	player.jump_velocity = -(560.0 + float(mods[&"jump_power"]))
	health.max_health = 5 + int(mods[&"max_health"])
	health.invulnerability_seconds = 0.35 + float(mods[&"invulnerability"])
	health.restore_full()

	combat.ground_damage = 1 + int(mods[&"damage"])
	combat.air_damage = 1 + int(mods[&"damage"]) + int(mods[&"air_damage"])
	combat.electrical_proc_chance = clampf(0.25 + float(mods[&"proc_chance"]), 0.0, 1.0)
	combat.attack_cooldown = maxf(0.12, 0.30 - float(mods[&"cooldown_reduction"]))
	combat.chain_lightning_enabled = float(mods[&"chain_lightning"]) > 0.0
	combat.on_kill_aoe_enabled = float(mods[&"on_kill_aoe"]) > 0.0
