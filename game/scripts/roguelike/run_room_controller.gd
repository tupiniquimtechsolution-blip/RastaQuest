extends Node2D

const EnemyScene = preload("res://scenes/enemies/EnemyBase.tscn")
const FinalBossScene = preload("res://scenes/boss/RiftSovereign.tscn")
const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")

const FINAL_BOSS_DEPTH: int = 18
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
var _boss_active: bool = false
var _returning_after_death: bool = false
var _portal_transitioning: bool = false
var _portal_entry_resolved: bool = false
var _portal_entry_id: int = 0

func _ready() -> void:
	portal.portal_entered.connect(_on_portal_entered)
	player.get_node("Health").died.connect(_on_player_died)
	player.get_node("Health").damaged.connect(_on_player_entry_interrupted)
	for index in range(reward_buttons.size()):
		reward_buttons[index].pressed.connect(_on_upgrade_selected.bind(index))
	if not RunManager.state.run_active:
		RunManager.start_run(424242)
	_apply_run_modifiers()
	_start_encounter()

func _start_encounter() -> void:
	_portal_entry_id += 1
	_portal_transitioning = false
	_portal_entry_resolved = false
	reward_panel.visible = false
	portal.set_locked(true)
	_clear_enemies()
	if RunManager.state.depth >= FINAL_BOSS_DEPTH:
		_start_final_boss()
		return
	_boss_active = false
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
		enemy.data = ENEMY_DATA.get(behavior, ENEMY_DATA["chaser"])
		enemy.target_path = NodePath("../../Player")
		enemy.position = room.spawn_positions[index] if index < room.spawn_positions.size() else Vector2(600 + index * 140, 610)
		enemy.enemy_defeated.connect(_on_enemy_defeated)
		$Enemies.add_child(enemy)
	status_label.text = "%s • %s • Encounter %d" % [room.title, String(RunManager.state.biome).capitalize(), RunManager.state.depth + 1]

func _start_final_boss() -> void:
	_boss_active = true
	_alive_enemies = 1
	backdrop.color = Color(0.06, 0.02, 0.09, 1.0)
	var boss := FinalBossScene.instantiate()
	boss.target_path = NodePath("../../Player")
	boss.position = Vector2(850, 585)
	boss.boss_defeated.connect(_on_boss_defeated)
	$Enemies.add_child(boss)
	status_label.text = "Rift Sovereign • Final fracture"

func _clear_enemies() -> void:
	for child in $Enemies.get_children():
		child.queue_free()

func _on_enemy_defeated(_enemy: Node) -> void:
	_alive_enemies = maxi(_alive_enemies - 1, 0)
	if _alive_enemies == 0 and not _returning_after_death and not _portal_transitioning:
		get_node("/root/ArtCatalog").burst("reward",portal.global_position,self,64,.45)
		portal.set_locked(false)
		status_label.text = "Encounter clear • Enter the portal"

func _on_boss_defeated() -> void:
	_alive_enemies = 0
	if _returning_after_death or _portal_transitioning:
		return
	portal.set_locked(false)
	status_label.text = "Rift Sovereign defeated • Victory portal open"

func _on_portal_entered() -> void:
	if _returning_after_death or _portal_transitioning or portal.locked or player.get_node("Health").dead:
		return
	if not player.can_attack():
		return
	_portal_transitioning = true
	_portal_entry_id += 1
	var entry_id := _portal_entry_id
	portal.set_locked(true)
	var seconds: float = portal.start_entry_presentation()
	player.begin_portal_entry(seconds)
	if seconds > 0.0:
		await get_tree().create_timer(seconds, false).timeout
	if not is_inside_tree() or _returning_after_death or entry_id != _portal_entry_id:
		return
	if not player.is_entering_portal():
		_cancel_portal_entry()
		return
	call_deferred("_complete_portal_entry", entry_id)

func _complete_portal_entry(entry_id: int) -> void:
	if _returning_after_death or not _portal_transitioning or _portal_entry_resolved or entry_id != _portal_entry_id:
		return
	if not player.is_entering_portal():
		_cancel_portal_entry()
		return
	_portal_entry_resolved = true
	if _boss_active:
		SaveManager.add_meta_shards(25)
		SaveManager.set_completion_flag(&"campaign_complete", true)
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

func _on_player_entry_interrupted(_amount: int, _remaining: int) -> void:
	if _portal_transitioning and not _portal_entry_resolved:
		_cancel_portal_entry()

func _cancel_portal_entry() -> void:
	_portal_entry_id += 1
	_portal_transitioning = false
	portal.cancel_entry_presentation()
	portal.set_locked(_alive_enemies > 0 or _returning_after_death)

func _on_upgrade_selected(index: int) -> void:
	if _returning_after_death:
		return
	if index < 0 or index >= _pending_choices.size():
		return
	var upgrade: UpgradeData = _pending_choices[index]
	_pending_choices.clear()
	RunManager.apply_upgrade(upgrade)
	RunManager.advance_encounter()
	_apply_run_modifiers()
	player.respawn()
	_start_encounter()

func _on_player_died() -> void:
	if _returning_after_death:
		return
	_returning_after_death = true
	_portal_entry_id += 1
	portal.cancel_entry_presentation()
	portal.set_locked(true)
	reward_panel.visible = false
	_pending_choices.clear()
	var delay: float = player.get_node("Visual").death_presentation_seconds()
	SaveManager.add_meta_shards(maxi(1, RunManager.state.depth))
	RunManager.end_run()
	if delay > 0.0:
		await get_tree().create_timer(delay, false).timeout
	if not is_inside_tree():
		return
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
