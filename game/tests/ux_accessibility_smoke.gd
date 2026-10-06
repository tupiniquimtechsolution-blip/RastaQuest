extends SceneTree

const SettingsManagerScript = preload("res://scripts/core/settings_manager.gd")
const SaveManagerScript = preload("res://scripts/save/save_manager.gd")

func _init() -> void:
	if not _test_normalization():
		return
	if not _test_settings_save_shape():
		return
	if load("res://scenes/ui/SettingsPanel.tscn") == null:
		_fail("settings scene failed to load")
		return
	if load("res://scenes/ui/OnboardingOverlay.tscn") == null:
		_fail("onboarding scene failed to load")
		return
	if not FileAccess.file_exists("res://localization/strings.csv"):
		_fail("localization structure missing")
		return
	if not FileAccess.file_exists("res://data/narrative/lore.json"):
		_fail("narrative contract missing")
		return
	print("RQ008_UX_ACCESSIBILITY_TECH_OK locales=2 settings=7")
	quit(0)

func _test_normalization() -> bool:
	var normalized := SettingsManagerScript.normalize({
		"music_volume": 2.0,
		"sfx_volume": -1.0,
		"touch_scale": 3.0,
		"locale": "invalid",
		"reduced_flashes": true,
	})
	if float(normalized["music_volume"]) != 1.0:
		return _fail("music volume was not clamped")
	if float(normalized["sfx_volume"]) != 0.0:
		return _fail("sfx volume was not clamped")
	if float(normalized["touch_scale"]) != 1.5:
		return _fail("touch scale was not clamped")
	if String(normalized["locale"]) != "en":
		return _fail("invalid locale did not fall back to English")
	if not bool(normalized["reduced_flashes"]):
		return _fail("accessibility boolean was not preserved")
	return true

func _test_settings_save_shape() -> bool:
	var manager := SaveManagerScript.new()
	manager.data = manager.default_data()
	var settings: Dictionary = manager.data["settings"]
	for key in ["screen_shake","reduced_flashes","vibration","music_volume","sfx_volume","touch_scale","locale"]:
		if not settings.has(key):
			return _fail("missing settings key: %s" % key)
	return true

func _fail(message: String) -> bool:
	push_error(message)
	quit(1)
	return false
