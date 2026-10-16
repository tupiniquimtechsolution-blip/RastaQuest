extends SceneTree

func _init() -> void:
	var version := String(ProjectSettings.get_setting("application/config/version", ""))
	if version != "1.0.0-rc.1":
		_fail("unexpected project RC version: %s" % version)
		return

	var preset_text := FileAccess.get_file_as_string("res://export_presets.cfg")
	for expected in [
		'name="Android Debug"',
		'architectures/arm64-v8a=true',
		'architectures/armeabi-v7a=true',
		'package/unique_name="com.tupiniquimtechsolution.rastaquest"',
		'version/code=1000001',
		'version/name="1.0.0-rc.1"',
	]:
		if not preset_text.contains(expected):
			_fail("missing export setting: %s" % expected)
			return

	var presets := ConfigFile.new()
	if presets.load("res://export_presets.cfg") != OK:
		_fail("cannot load Android export preset")
		return
	for abi in ["armeabi-v7a", "arm64-v8a"]:
		if presets.get_value("preset.0.options", "architectures/" + abi, false) != true:
			_fail("Android Debug is missing ABI: %s" % abi)
			return

	print("RQ010_RC_PREP_OK version=1.0.0-rc.1 arm64=1 armv7=1")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	quit(1)
