extends RefCounted

const RoomCatalog = preload("res://scripts/roguelike/room_catalog.gd")
const UpgradeCatalog = preload("res://scripts/roguelike/upgrade_catalog.gd")
const EncounterDirector = preload("res://scripts/enemies/encounter_director.gd")

static func validate_content() -> Array[String]:
	var errors: Array[String] = []
	var rooms := RoomCatalog.load_all()
	var upgrades := UpgradeCatalog.load_all()

	if rooms.size() != 18:
		errors.append("expected 18 rooms")
	if upgrades.size() != 18:
		errors.append("expected 18 upgrades")

	for room in rooms:
		if room == null:
			errors.append("null room")
			continue
		if room.enemy_archetypes.size() > 4:
			errors.append("room %s exceeds baseline enemy-count cap" % room.id)
		if room.spawn_positions.size() < room.enemy_archetypes.size():
			errors.append("room %s has insufficient spawn positions" % room.id)

	for upgrade in upgrades:
		if upgrade == null:
			errors.append("null upgrade")
			continue
		if upgrade.effect_key == &"":
			errors.append("upgrade %s has no effect key" % upgrade.id)
		if not is_finite(upgrade.effect_value):
			errors.append("upgrade %s has non-finite effect" % upgrade.id)

	var director := EncounterDirector.new(8, 2)
	if not director.register_enemy(1, 3, true):
		errors.append("director rejected valid high-threat enemy 1")
	if not director.register_enemy(2, 3, true):
		errors.append("director rejected valid high-threat enemy 2")
	if director.register_enemy(3, 1, true):
		errors.append("director allowed high-threat cap overflow")
	if director.register_enemy(4, 3, false):
		errors.append("director allowed budget overflow")

	return errors
