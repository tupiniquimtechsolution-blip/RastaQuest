extends Node2D

const EnemyScene = preload("res://scenes/enemies/EnemyBase.tscn")
const FinalBossScene = preload("res://scenes/boss/FractureKing.tscn")
const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")
const LoreCatalog = preload("res://scripts/product/lore_catalog.gd")

const ENCOUNTERS_PER_BIOME: int = 4
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
@onready var reward_buttons: Array[Button] = [$Hud/RewardPanel/VBox/Choice1, $Hud/RewardPanel/VBox/Choice2, $Hud/RewardPanel/VBox/Choice3]
@onready var status_label: Label = $Hud/Status

var _alive_enemies: int = 0
var _pending_choices: Array = []
var _final_boss_active: bool = false

func _ready() -> void:
	portal.portal_entered.connect(_on_portal_entered)
	player.get_node("Health").died.connect(_on_player_died)
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

	if RunManager.state.biome == &"cave" and RunManager.state.biome_depth >= ENCOUNTERS_PER_BIOME:
		_start_final_boss()
		return

	_final_boss_active = false
	var rooms := RoomCatalog.load_biome(RunManager.state.biome)
	var room_id := RunManager.state.choose_room(RoomCatalog.ids(rooms))
	var room: RoomTemplateData = RoomCatalog.by_id(rooms, room_id)
	if room == null:
		status_label.text = "Invalid room template"
		return

	backdrop.color = room.background_color
	_alive_enemies = room.enemy_archetypes.size()
	for index in range(room.enemy_archetypes.size()):
		var enemy := EnemyScene.instantiate()
		var behavior := room.enemy_archetypes[index]
		var base_data: EnemyData = ENEMY_DATA.get(behavior, ENEMY_DATA["chaser"])
		enemy.data = _biome_variant(base_data, RunManager.state.biome, room.elite_room and index == room.enemy_archetypes.size() - 1)
		enemy.target_path = NodePath("../../Player")
		enemy.position = room.spawn_positions[index] if index < room.spawn_positions.size() else Vector2(600 + index * 140, 610)
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		$Enemies.add_child(enemy)

	status_label.text = "%s • %s • %s" % [LoreCatalog.title(RunManager.state.biome), room.title, LoreCatalog.intro(RunManager.state.biome)]

func _biome_variant(base_data: EnemyData, biome: StringName, elite: bool) -> EnemyData:
	var result: EnemyData = base_data.duplicate()
	if biome == &"castle":
		result.max_health += 1
		result.move_speed *= 1.08
		result.attack_cooldown *= 0.92
	elif biome == &"cave":
		result.max_health += 2
		result.move_speed *= 1.14
		result.attack_cooldown *= 0.84
	if elite:
		result.max_health += 2
		result.move_speed *= 1.15
		result.encounter_cost += 1
		result.high_threat = true
	return result

func _start_final_boss() -> void:
	_final_boss_active = true
	_alive_enemies = 1
	backdrop.color = Color(0.08, 0.035, 0.11, 1.0)
	var boss := FinalBossScene.instantiate()
	boss.position = Vector2(850, 580)
	boss.boss_defeated.connect(_on_final_boss_defeated)
	$Enemies.add_child(boss)
	status_label.text = "Fracture King • Source of the collapsing portals"

func _clear_enemies() -> void:
	for child in $Enemies.get_children():
		child.queue_free()

func _on_enemy_defeated(_enemy: Node) -> void:
	_alive_enemies = maxi(_alive_enemies - 1, 0)
	if _alive_enemies == 0:
		portal.set_locked(false)
		status_label.text = "Encounter clear • Enter the portal"

func _on_final_boss_defeated() -> void:
	_alive_enemies = 0
	portal.set_locked(false)
	status_label.text = "Fracture King defeated • The rift stabilizes"

func _on_portal_entered() -> void:
	portal.set_locked(true)
	if _final_boss_active:
		SaveManager.add_meta_shards(20)
		SaveManager.set_completion_flag(&"campaign_complete", true)
		RunManager.end_run()
		get_tree().change_scene_to_file("res://scenes/hub/Hub.tscn")
		return

	_pending_choices = RunManager.sample_upgrade_choices(3)
	if _pending_choices.is_empty():
		_progress_after_reward()
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
	RunManager.apply_upgrade(_pending_choices[index])
	_progress_after_reward()

func _progress_after_reward() -> void:
	RunManager.advance_encounter()
	if RunManager.state.biome_depth >= ENCOUNTERS_PER_BIOME and RunManager.state.biome != &"cave":
		RunManager.advance_biome()
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
