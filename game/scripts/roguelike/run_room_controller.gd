extends Node2D

const EnemyScene = preload("res://scenes/enemies/EnemyBase.tscn")
const ENEMY_DATA := [
	preload("res://data/enemies/chaser.tres"),
	preload("res://data/enemies/ranged.tres"),
	preload("res://data/enemies/charger.tres"),
	preload("res://data/enemies/controller.tres"),
]

@onready var player: CharacterBody2D = $Player
@onready var portal: Area2D = $Portal
@onready var reward_panel: Control = $Hud/RewardPanel
@onready var reward_buttons: Array[Button] = [
	$Hud/RewardPanel/VBox/Choice1,
	$Hud/RewardPanel/VBox/Choice2,
	$Hud/RewardPanel/VBox/Choice3,
]
@onready var status_label: Label = $Hud/Status

var _alive_enemies: int = 0
var _pending_choices: Array = []

func _ready() -> void:
	portal.portal_entered.connect(_on_portal_entered)
	for index in range(reward_buttons.size()):
		reward_buttons[index].pressed.connect(_on_upgrade_selected.bind(index))

	if not RunManager.state.run_active:
		RunManager.start_run(424242)

	_apply_run_modifiers()
	_start_encounter()

func _start_encounter() -> void:
	reward_panel.visible = false
	portal.set_locked(true)
	_clear_enemies()

	var depth: int = RunManager.state.depth
	var count: int = mini(2 + int(depth / 3), 4)
	_alive_enemies = count

	for index in range(count):
		var enemy := EnemyScene.instantiate()
		enemy.data = ENEMY_DATA[(depth + index) % ENEMY_DATA.size()]
		enemy.target_path = NodePath("../Player")
		enemy.position = Vector2(560 + index * 150, 610)
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		$Enemies.add_child(enemy)

	status_label.text = "Run seed %d • Encounter %d • Enemies %d" % [RunManager.state.seed_value, depth + 1, count]

func _clear_enemies() -> void:
	for child in $Enemies.get_children():
		child.queue_free()

func _on_enemy_defeated(_enemy: Node) -> void:
	_alive_enemies = maxi(_alive_enemies - 1, 0)
	if _alive_enemies == 0:
		portal.set_locked(false)
		status_label.text = "Encounter clear • Enter the portal"

func _on_portal_entered() -> void:
	portal.set_locked(true)
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

func _apply_run_modifiers() -> void:
	var mods: Dictionary = RunManager.state.modifiers
	var controller := player
	var combat: Node = player.get_node("PlayerCombat")
	var health: Node = player.get_node("Health")

	controller.move_speed = 260.0 + float(mods[&"move_speed"])
	controller.jump_velocity = -(560.0 + float(mods[&"jump_power"]))
	health.max_health = 5 + int(mods[&"max_health"])
	health.invulnerability_seconds = 0.35 + float(mods[&"invulnerability"])
	health.restore_full()

	combat.ground_damage = 1 + int(mods[&"damage"])
	combat.air_damage = 1 + int(mods[&"damage"]) + int(mods[&"air_damage"])
	combat.electrical_proc_chance = clampf(0.25 + float(mods[&"proc_chance"]), 0.0, 1.0)
	combat.attack_cooldown = maxf(0.12, 0.30 - float(mods[&"cooldown_reduction"]))
	combat.chain_lightning_enabled = float(mods[&"chain_lightning"]) > 0.0
	combat.on_kill_aoe_enabled = float(mods[&"on_kill_aoe"]) > 0.0
