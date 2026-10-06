extends RefCounted

const DEFAULTS := {
	"screen_shake": true,
	"reduced_flashes": false,
	"vibration": true,
	"music_volume": 1.0,
	"sfx_volume": 1.0,
	"touch_scale": 1.0,
	"locale": "en",
}

static func normalize(source: Dictionary) -> Dictionary:
	var result := DEFAULTS.duplicate(true)
	for key in source:
		if result.has(key):
			result[key] = source[key]
	result["music_volume"] = clampf(float(result["music_volume"]), 0.0, 1.0)
	result["sfx_volume"] = clampf(float(result["sfx_volume"]), 0.0, 1.0)
	result["touch_scale"] = clampf(float(result["touch_scale"]), 0.75, 1.5)
	if String(result["locale"]) not in ["en", "pt_BR"]:
		result["locale"] = "en"
	return result
