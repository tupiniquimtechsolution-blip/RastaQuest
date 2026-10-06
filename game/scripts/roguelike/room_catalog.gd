extends RefCounted

const FOREST_PATHS: Array[String] = [
	"res://data/encounters/forest_gate.tres",
	"res://data/encounters/forest_bridge.tres",
	"res://data/encounters/forest_shrine.tres",
	"res://data/encounters/forest_roots.tres",
	"res://data/encounters/forest_ruin.tres",
	"res://data/encounters/forest_storm.tres",
]
const CASTLE_PATHS: Array[String] = [
	"res://data/encounters/castle_gate.tres",
	"res://data/encounters/castle_hall.tres",
	"res://data/encounters/castle_tower.tres",
	"res://data/encounters/castle_chapel.tres",
	"res://data/encounters/castle_armory.tres",
	"res://data/encounters/castle_throne.tres",
]
const CAVE_PATHS: Array[String] = [
	"res://data/encounters/cave_mouth.tres",
	"res://data/encounters/cave_echo.tres",
	"res://data/encounters/cave_crystal.tres",
	"res://data/encounters/cave_chasm.tres",
	"res://data/encounters/cave_shrine.tres",
	"res://data/encounters/cave_abyss.tres",
]

static func _load_paths(paths: Array[String]) -> Array:
	var result: Array = []
	for path in paths:
		result.append(load(path))
	return result

static func load_forest() -> Array:
	return _load_paths(FOREST_PATHS)

static func load_castle() -> Array:
	return _load_paths(CASTLE_PATHS)

static func load_caves() -> Array:
	return _load_paths(CAVE_PATHS)

static func load_biome(biome: StringName) -> Array:
	match biome:
		&"castle":
			return load_castle()
		&"caves":
			return load_caves()
		_:
			return load_forest()

static func load_all() -> Array:
	var result: Array = []
	result.append_array(load_forest())
	result.append_array(load_castle())
	result.append_array(load_caves())
	return result

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
