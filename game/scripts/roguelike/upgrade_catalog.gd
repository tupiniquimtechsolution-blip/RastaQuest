extends RefCounted

const UPGRADE_PATHS: Array[String] = [
	"res://data/upgrades/raw_power.tres",
	"res://data/upgrades/aerial_edge.tres",
	"res://data/upgrades/fleet_step.tres",
	"res://data/upgrades/sky_blessing.tres",
	"res://data/upgrades/hard_skin.tres",
	"res://data/upgrades/long_grace.tres",
	"res://data/upgrades/storm_spark.tres",
	"res://data/upgrades/chain_storm.tres",
	"res://data/upgrades/thunder_fall.tres",
	"res://data/upgrades/quick_hands.tres",
	"res://data/upgrades/heavy_axe.tres",
	"res://data/upgrades/wind_dance.tres",
]

static func load_all() -> Array:
	var upgrades: Array = []
	for path in UPGRADE_PATHS:
		upgrades.append(load(path))
	return upgrades
