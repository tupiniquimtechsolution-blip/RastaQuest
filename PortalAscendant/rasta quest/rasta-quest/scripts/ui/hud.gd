extends Control

@onready var life_label: Label = $MarginContainer/HBoxContainer/LifeLabel
@onready var score_label: Label = $MarginContainer/HBoxContainer/ScoreLabel

func update_life(value: int):
	life_label.text = "❤️ Vida: %d" % value

func update_score(value: int):
	score_label.text = "⭐ Pontos: %d" % value
