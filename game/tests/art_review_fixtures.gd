extends RefCounted

## Loads draft pixels only for tests/review. Never referenced by shipping scenes.
static func texture(relative: String) -> Texture2D:
	var image := Image.new()
	var path := ProjectSettings.globalize_path("res://../assets/production_drafts/2026-10-22/") + relative
	if image.load(path) != OK:
		return null
	return ImageTexture.create_from_image(image)

static func body_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	var clips := {
		&"idle": ["axe-idle-2x/player_idle_%02d.png", [200, 200, 200, 200]],
		&"run": ["run-2x/player_run_%02d.png", [60, 60, 60, 60, 60, 60]],
		&"jump": ["airborne-2x/jump_combined_%02d.png", [100]],
		&"fall": ["airborne-2x/fall_combined_%02d.png", [100]],
		&"attack_axe": ["combat-reaction-2x/attack_axe_%02d_combined.png", [40, 40, 40, 40]],
		&"attack_axe_air": ["combat-reaction-2x/attack_axe_air_%02d_combined.png", [50, 55, 55]],
		&"hurt": ["combat-reaction-2x/hurt_%02d_combined.png", [90, 90]],
		&"death": ["combat-reaction-2x/death_%02d_combined.png", [120, 140, 160, 180]],
	}
	for clip in clips:
		frames.add_animation(clip)
		frames.set_animation_loop(clip, clip in [&"idle", &"run"])
		frames.set_animation_speed(clip, 1000.0)
		for index in range(clips[clip][1].size()):
			var tex := texture(clips[clip][0] % (index + 1))
			if tex == null:
				return null
			frames.add_frame(clip, tex, clips[clip][1][index])
	return frames

static func portal_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.add_animation(&"idle")
	frames.add_frame(&"idle", texture("effects-2x/fx_portal_interaction_02.png"))
	frames.add_animation(&"enter")
	frames.set_animation_loop(&"enter", false)
	frames.set_animation_speed(&"enter", 1000.0)
	for index in range(1, 5):
		frames.add_frame(&"enter", texture("effects-2x/fx_portal_interaction_%02d.png" % index), 90.0)
	return frames

static func assign(player: Node, portal: Node) -> bool:
	var visual := player.get_node("Visual")
	visual.dropped_weapon_texture = texture("combat-reaction-2x/death_01_weapon.png")
	return visual.apply_frames(body_frames()) and portal.apply_frames(portal_frames())
