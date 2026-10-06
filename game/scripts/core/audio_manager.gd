extends Node

const REQUIRED_BUSES: Array[StringName] = [&"Music", &"SFX"]

func _ready() -> void:
	for bus_name in REQUIRED_BUSES:
		_ensure_bus(bus_name)

func set_bus_linear(bus_name: StringName, linear_value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	var clamped := clampf(linear_value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(clamped, 0.0001)))
	AudioServer.set_bus_mute(index, clamped <= 0.0)

func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	var index := AudioServer.bus_count - 1
	AudioServer.set_bus_name(index, bus_name)
