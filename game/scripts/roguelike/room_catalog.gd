extends RefCounted

const FOREST_PATHS: Array[String] = [
	"res://data/encounters/forest_gate.tres",
	"res://data/encounters/forest_bridge.tres",
	"res://data/encounters/forest_shrine.tres",
	"res://data/encounters/forest_roots.tres",
	"res://data/encounters/forest_ruin.tres",
	"res://data/encounters/forest_storm.tres",
]

static func load_forest() -> Array:
	var result: Array = []
	for path in FOREST_PATHS:
		result.append(load(path))
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
