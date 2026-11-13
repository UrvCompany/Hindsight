
extends ColorRect

@onready var viewport_label: Label = $ViewportLabel
@onready var window_label: Label = $WindowLabel

@onready var windowed_button: Button = $WindowedButton
@onready var borderless_button: Button = $BorderlessButton
@onready var fullscreen_button: Button = $FullscreenButton
@onready var resolution_720_button: Button = $Resolution720Button
@onready var resolution_1080_button: Button = $Resolution1080Button


func _ready() -> void:
	windowed_button.pressed.connect(
		func(): SettingsManager.set_display_mode(SettingsManager.MODE_WINDOWED)
	)

	borderless_button.pressed.connect(
		func(): SettingsManager.set_display_mode(SettingsManager.MODE_BORDERLESS)
	)

	fullscreen_button.pressed.connect(
		func(): SettingsManager.set_display_mode(SettingsManager.MODE_FULLSCREEN)
	)

	resolution_720_button.pressed.connect(
		func(): SettingsManager.set_windowed_resolution(Vector2i(1280, 720))
	)

	resolution_1080_button.pressed.connect(
		func(): SettingsManager.set_windowed_resolution(Vector2i(1920, 1080))
	)

	SettingsManager.display_settings_changed.connect(_update_info)

	_update_info()


func _process(_delta: float) -> void:
	_update_info()

## ЗАЛУПА КОНСКАЯ
func _update_info() -> void:
	var window := get_window()
	var viewport := get_viewport()

	viewport_label.text = (
		"Viewport: %s\n"
		+ "Visible rect: %s\n"
		+ "Window ID: %s"
	) % [
		str(viewport.size),
		str(viewport.get_visible_rect()),
		str(window.get_window_id())
	]

	window_label.text = (
		"Window size: %s\n"
		+ "Window position: %s\n"
		+ "Window mode: %s\n"
		+ "Borderless: %s\n"
		+ "Saved resolution: %s\n"
		+ "Manager mode: %s"
	) % [
		str(window.size),
		str(window.position),
		str(window.mode),
		str(window.borderless),
		str(SettingsManager.windowed_resolution),
		SettingsManager.display_mode
	]
