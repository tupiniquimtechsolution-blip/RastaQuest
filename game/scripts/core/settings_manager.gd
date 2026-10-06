extends Node

signal settings_changed

const SettingsPolicy = preload("res://scripts/core/settings_policy.gd")

var values: Dictionary = SettingsPolicy.DEFAULTS.duplicate(true)

func _ready() -> void:
	reload_from_save()

func reload_from_save() -> void:
	values = SettingsPolicy.normalize(SaveManager.data.get("settings", {}))
	apply_runtime()

func set_value(key: StringName, value: Variant) -> void:
	var candidate := values.duplicate(true)
	candidate[String(key)] = value
	values = SettingsPolicy.normalize(candidate)
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
