extends Resource
class_name RoomTemplateData

@export var id: StringName
@export var title: String = "Room"
@export var enemy_archetypes: Array[String] = []
@export var spawn_positions: Array[Vector2] = []
@export var background_color: Color = Color(0.05, 0.08, 0.05, 1.0)
@export var elite_room: bool = false
