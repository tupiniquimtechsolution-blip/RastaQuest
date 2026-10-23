extends SceneTree

func _init() -> void:
	call_deferred("_run")

func _frames(count: int = 2) -> void:
	for _i in range(count):
		await process_frame

func _run() -> void:
	# Load after autoload singletons are initialized by the custom SceneTree runner.
	var Hub: PackedScene = load("res://scenes/hub/Hub.tscn")
	var Pause: PackedScene = load("res://scenes/ui/PauseOverlay.tscn")
	var RunRoom: PackedScene = load("res://scenes/world/RunPrototypeRoom.tscn")
	var save: Node = root.get_node("SaveManager")
	var settings: Node = root.get_node("SettingsManager")
	save.configure_paths("user://rq_ui_access.json", "user://rq_ui_access.bak.json")
	save.data = save.default_data()
	settings.reload_from_save()
	var hub := Hub.instantiate()
	root.add_child(hub)
	await _frames()
	hub.get_node("Hud/Panel/VBox/Settings").pressed.emit()
	await _frames()
	var panel: Control = hub._menu_layer.get_child(0)
	panel.music.value = 0.35
	panel.sfx.value = 0.0
	panel.locale.select(1)
	panel.locale.item_selected.emit(1)
	await _frames()
	if tr("start_run") != "Iniciar partida" or not hub.shards_label.text.begins_with("Fragmentos:"):
		_fail("PT-BR catalog or live hub translation did not load")
		return
	panel.locale.select(2)
	panel.locale.item_selected.emit(2)
	await _frames()
	if tr("start_run") != "Iniciar partida" or tr("settings_title") != "Configuración / Accesibilidad":
		_fail("Spanish catalog did not update live: %s / %s / %s" % [TranslationServer.get_locale(),tr("start_run"),tr("settings_title")])
		return
	panel.locale.select(1)
	panel.locale.item_selected.emit(1)
	await _frames()
	var stored: Dictionary = save.load_save()
	if stored["settings"]["locale"] != "pt_BR" or not is_equal_approx(float(stored["settings"]["music_volume"]), 0.35):
		_fail("settings menu did not persist language/volume")
		return
	if not is_equal_approx(db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music"))), 0.35) or not AudioServer.is_bus_mute(AudioServer.get_bus_index("SFX")):
		_fail("settings menu did not apply actual audio bus values")
		return
	# Inspect containment at supported logical viewport aspect ratios.
	for size in [Vector2i(1280, 720), Vector2i(1600, 720), Vector2i(960, 720)]:
		root.size = size
		await _frames()
		var bounds: Rect2 = panel.get_node("Panel").get_global_rect()
		if bounds.position.x < 0.0 or bounds.position.y < 0.0 or bounds.end.x > root.get_visible_rect().size.x or bounds.end.y > root.get_visible_rect().size.y:
			_fail("settings panel escaped logical viewport: %s" % size)
			return
	panel.get_node("Panel/Close").pressed.emit()
	await _frames()
	if is_instance_valid(hub._menu_layer):
		_fail("settings close left a blocking overlay")
		return
	hub.get_node("Hud/Panel/VBox/Credits").pressed.emit()
	await _frames()
	var credits: Control = hub._menu_layer.get_child(0)
	if not credits.get_node("Panel/VBox/Notices").text.contains("Permission is hereby granted"):
		_fail("credits did not expose the engine license")
		return
	credits.get_node("Panel/VBox/Close").pressed.emit()
	await _frames()

	var pause := Pause.instantiate()
	root.add_child(pause)
	pause._set_paused(true)
	pause.get_node("Panel/VBox/Settings").pressed.emit()
	await _frames()
	var paused_settings: Control = pause._settings_layer.get_child(0)
	paused_settings.locale.select(0)
	paused_settings.locale.item_selected.emit(0)
	await _frames()
	if tr("start_run") != "Start Run":
		_fail("language selection failed while paused")
		return
	paused_settings.get_node("Panel/Close").pressed.emit()
	await _frames()
	if not paused:
		_fail("closing settings unexpectedly resumed combat")
		return
	pause.resume_button.pressed.emit()
	if paused:
		_fail("resume button did not resume")
		return
	pause.queue_free()
	hub.queue_free()
	await _frames()

	# The real run must present onboarding, pause danger, then persist completion.
	save.data["completion_flags"]["tutorial_complete"] = false
	var run_room := RunRoom.instantiate()
	root.add_child(run_room)
	await _frames()
	if not paused or not run_room.has_node("OnboardingOverlay"):
		_fail("new run did not show a protected onboarding")
		return
	var onboarding: CanvasLayer = run_room.get_node("OnboardingOverlay")
	for _i in range(3):
		onboarding.continue_button.pressed.emit()
		await _frames()
	if paused or not save.completion_flag(&"tutorial_complete"):
		_fail("onboarding did not release pause and persist completion")
		return
	var controls: CanvasLayer = run_room.get_node("TouchControls")
	settings.set_value(&"touch_scale", 1.5)
	await _frames()
	if not is_equal_approx(controls.jump_button.size.x, 192.0) or controls.joystick.get_global_rect().intersects(controls.attack_button.get_global_rect()):
		_fail("touch scale did not resize/reflow actual controls")
		return
	controls.joystick.finger = 0
	controls.joystick._move(controls.joystick.global_position+Vector2(0,controls.joystick.size.y*.5))
	if not Input.is_action_pressed("move_left"):
		_fail("touch hold did not enter InputMap")
		return
	controls.pause_button._press(controls.pause_button.global_position+controls.pause_button.size*.5)
	await _frames()
	if not paused:
		_fail("on-screen pause button did not pause the real run")
		return
	if Input.is_action_pressed("move_left"):
		_fail("pause left a held touch movement active")
		return
	run_room.get_node("PauseOverlay")._set_paused(false)
	controls.attack_button.finger = 1
	controls.attack_button._press(controls.attack_button.global_position+controls.attack_button.size*.5)
	controls._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	if Input.is_action_pressed("attack"):
		_fail("focus loss left a held attack active")
		return
	run_room.queue_free()
	root.get_node("RunManager").end_run()
	await _frames()
	print("RQ_MENU_ACCESS_OK settings=reachable locales=3 pause=pass onboarding=pass notices=present")
	quit(0)

func _fail(message: String) -> void:
	push_error(message)
	paused = false
	quit(1)
