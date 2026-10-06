extends RefCounted

const FOREST_PATHS: Array[String] = [
	"res://data/encounters/forest_gate.tres", "res://data/encounters/forest_bridge.tres",
	"res://data/encounters/forest_shrine.tres", "res://data/encounters/forest_roots.tres",
	"res://data/encounters/forest_ruin.tres", "res://data/encounters/forest_storm.tres",
]
const CASTLE_PATHS: Array[String] = [
	"res://data/encounters/castle_gate.tres", "res://data/encounters/castle_hall.tres",
	"res://data/encounters/castle_tower.tres", "res://data/encounters/castle_chapel.tres",
	"res://data/encounters/castle_armory.tres", "res://data/encounters/castle_rift.tres",
]
const CAVE_PATHS: Array[String] = [
	"res://data/encounters/cave_mouth.tres", "res://data/encounters/cave_echo.tres",
	"res://data/encounters/cave_crystal.tres", "res://data/encounters/cave_depths.tres",
	"res://data/encounters/cave_abyss.tres", "res://data/encounters/cave_core.tres",
]

static func load_forest() -> Array:
	return _load_paths(FOREST_PATHS)

static func load_biome(biome: StringName) -> Array:
	match biome:
		&"castle":
			return _load_paths(CASTLE_PATHS)
		&"cave":
			return _load_paths(CAVE_PATHS)
		_:
			return _load_paths(FOREST_PATHS)

static func ids(rooms: Array) -> Array[StringName]:
	var result: Array[StringName] = []
	for room in rooms:
		result.append(room.id)
	return result

static func by_id(rooms: Array, room_id: StringName) -> RoomTemplateData:
	for room in rooms:
		if room.id == room_id:
			return room
	return null

static func _load_paths(paths: Array[String]) -> Array:
	var result: Array = []
	for path in paths:
		result.append(load(path))
	return result
