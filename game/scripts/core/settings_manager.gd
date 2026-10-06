extends Node

signal settings_changed

const DEFAULTS := {
	"screen_shake": true,
	"reduced_flashes": false,
	"vibration": true,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"touch_scale": 1.0,
	"locale": "en",
}

var values: Dictionary = DEFAULTS.duplicate(true)

func _ready() -> void:
	reload_from_save()

func reload_from_save() -> void:
	values = normalize(SaveManager.data.get("settings", {}))
	apply_runtime()

static func normalize(source: Dictionary) -> Dictionary:
	var result := DEFAULTS.duplicate(true)
	for key in source:
		if result.has(key):
			result[key] = source[key]
	result["music_volume"] = clampf(float(result["music_volume"]), 0.0, 1.0)
	result["sfx_volume"] = clampf(float(result["sfx_volume"]), 0.0, 1.0)
	result["touch_scale"] = clampf(float(result["touch_scale"]), 0.75, 1.5)
	if not String(result["locale"]) in ["en", "pt_BR"]:
		result["locale"] = "en"
	return result

func set_value(key: StringName, value: Variant) -> void:
	var candidate := values.duplicate(true)
	candidate[String(key)] = value
	values = normalize(candidate)
	SaveManager.data["settings"] = values.duplicate(true)
	SaveManager.save_current()
	apply_runtime()
	settings_changed.emit()

func get_value(key: StringName, fallback: Variant = null) -> Variant:
	return values.get(String(key), fallback)

func apply_runtime() -> void:
	AudioManager.set_bus_linear(&"Music", float(values["music_volume"]))
	AudioManager.set_bus_linear(&"SFX", float(values["sfx_volume"]))
	TranslationServer.set_locale(String(values["locale"]))

func screen_shake_enabled() -> bool:
	return bool(values["screen_shake"])

func reduced_flashes_enabled() -> bool:
	return bool(values["reduced_flashes"])

func vibration_enabled() -> bool:
	return bool(values["vibration"])
