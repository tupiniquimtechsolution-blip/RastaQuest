extends Node

var current_arena := 0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var hud = get_tree().get_first_node_in_group("hud")

func _ready():
	if player and hud:
		player.life_changed.connect(hud.update_life)
		player.score_changed.connect(hud.update_score)
	else:
		push_warning("Player ou HUD não encontrado nos grupos")

func next_arena():
	current_arena += 1
	get_tree().reload_current_scene()
