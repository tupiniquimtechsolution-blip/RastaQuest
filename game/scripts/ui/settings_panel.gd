extends Control

signal closed

@onready var screen_shake: CheckButton = $Panel/Scroll/VBox/ScreenShake
@onready var reduced_flashes: CheckButton = $Panel/Scroll/VBox/ReducedFlashes
@onready var vibration: CheckButton = $Panel/Scroll/VBox/Vibration
@onready var music: HSlider = $Panel/Scroll/VBox/Music
@onready var sfx: HSlider = $Panel/Scroll/VBox/Sfx
@onready var touch_scale: HSlider = $Panel/Scroll/VBox/TouchScale
@onready var locale: OptionButton = $Panel/Scroll/VBox/Locale

func _ready() -> void:
	$Panel/Close.pressed.connect(closed.emit)
	screen_shake.button_pressed = SettingsManager.screen_shake_enabled()
	reduced_flashes.button_pressed = SettingsManager.reduced_flashes_enabled()
	vibration.button_pressed = SettingsManager.vibration_enabled()
	music.value = float(SettingsManager.get_value(&"music_volume", 1.0))
	sfx.value = float(SettingsManager.get_value(&"sfx_volume", 1.0))
	touch_scale.value = float(SettingsManager.get_value(&"touch_scale", 1.0))
	locale.add_item("English")
	locale.set_item_metadata(0, "en")
	locale.add_item("Português (Brasil)")
	locale.set_item_metadata(1, "pt_BR")
	locale.add_item("Español")
	locale.set_item_metadata(2,"es")
	for index in range(locale.item_count):
		if locale.get_item_metadata(index) == SettingsManager.get_value(&"locale","pt_BR"):
			locale.select(index)

	screen_shake.toggled.connect(func(v): SettingsManager.set_value(&"screen_shake", v))
	reduced_flashes.toggled.connect(func(v): SettingsManager.set_value(&"reduced_flashes", v))
	vibration.toggled.connect(func(v): SettingsManager.set_value(&"vibration", v))
	music.value_changed.connect(func(v): SettingsManager.set_value(&"music_volume", v))
	sfx.value_changed.connect(func(v): SettingsManager.set_value(&"sfx_volume", v))
	touch_scale.value_changed.connect(func(v): SettingsManager.set_value(&"touch_scale", v))
	locale.item_selected.connect(_on_locale_selected)

func _on_locale_selected(index: int) -> void:
	SettingsManager.set_value(&"locale", locale.get_item_metadata(index))
