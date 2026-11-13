extends Node

signal display_settings_changed
signal preview_started(seconds: int)
signal preview_finished(accepted: bool)

const CONFIG_PATH := "user://settings.cfg"

const MODE_WINDOWED := "windowed"
const MODE_BORDERLESS := "borderless"
const MODE_FULLSCREEN := "fullscreen"

const DEFAULT_WINDOWED_RESOLUTION := Vector2i(1920, 1080)
const PREVIEW_DURATION := 15

const WINDOWED_RESOLUTIONS: Array[Vector2i] = [
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2560, 1440),
	Vector2i(3440, 1440),
	Vector2i(3840, 2160)
]

var display_mode := MODE_BORDERLESS
var windowed_resolution := DEFAULT_WINDOWED_RESOLUTION
var fullscreen_resolution: Dictionary = {}

var _resolution_manager: ResolutionManager
var _active_device_name := ""

var _preview_active := false
var _pending_preview_mode := MODE_WINDOWED

var _previous_mode := MODE_WINDOWED
var _previous_windowed_resolution := DEFAULT_WINDOWED_RESOLUTION
var _previous_fullscreen_resolution: Dictionary = {}

var _preview_timer: Timer


func _ready() -> void:
	_load_settings()

	_resolution_manager = ResolutionManager.new()
	_find_active_device()

	_preview_timer = Timer.new()
	_preview_timer.one_shot = true
	_preview_timer.timeout.connect(cancel_display_preview)
	add_child(_preview_timer)

	if display_mode == MODE_FULLSCREEN:
		if fullscreen_resolution.is_empty():
			fullscreen_resolution = _get_current_fullscreen_resolution()

		if not _set_monitor_resolution(fullscreen_resolution):
			display_mode = MODE_WINDOWED

	await _apply_display_mode(display_mode)
	


func get_active_screen() -> int:
	var screen := DisplayServer.window_get_current_screen()

	if screen < 0 or screen >= DisplayServer.get_screen_count():
		screen = DisplayServer.get_primary_screen()

	return screen


func get_current_display_resolution() -> Vector2i:
	return DisplayServer.screen_get_size(get_active_screen())


func get_available_windowed_resolutions() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var screen_size := get_current_display_resolution()

	for resolution in get_available_fullscreen_resolutions():
		var size := Vector2i(
			resolution["width"],
			resolution["height"]
		)

		if size.x > screen_size.x or size.y > screen_size.y:
			continue

		if size not in result:
			result.append(size)

	result.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		if a.x != b.x:
			return a.x < b.x

		return a.y < b.y
	)

	return result


func get_available_fullscreen_resolutions() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	if _resolution_manager == null or _active_device_name.is_empty():
		return result

	var monitors := _resolution_manager.get_available_monitors()

	for monitor in monitors:
		if monitor["device_name"] != _active_device_name:
			continue

		for resolution in monitor["resolutions"]:
			var entry := {
				"width": int(resolution["width"]),
				"height": int(resolution["height"]),
				"device_name": _active_device_name
			}

			if entry not in result:
				result.append(entry)

		break

	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if a["width"] != b["width"]:
			return a["width"] < b["width"]

		return a["height"] < b["height"]
	)

	return result


func get_available_fullscreen_refresh_rates(width: int, height: int) -> Array[int]:
	var result: Array[int] = []

	if _resolution_manager == null or _active_device_name.is_empty():
		return result

	var monitors := _resolution_manager.get_available_monitors()

	for monitor in monitors:
		if monitor["device_name"] != _active_device_name:
			continue

		for resolution in monitor["resolutions"]:
			if int(resolution["width"]) != width:
				continue

			if int(resolution["height"]) != height:
				continue

			var rate := int(resolution["refresh_rate"])

			if rate not in result:
				result.append(rate)

		break

	result.sort()

	return result


func _find_active_device() -> void:
	if _resolution_manager == null:
		return

	var monitors := _resolution_manager.get_available_monitors()

	for monitor in monitors:
		if monitor["is_primary"]:
			_active_device_name = monitor["device_name"]
			return

	if not monitors.is_empty():
		_active_device_name = monitors[0]["device_name"]


func _get_current_fullscreen_resolution() -> Dictionary:
	var screen := get_active_screen()
	var size := DisplayServer.screen_get_size(screen)
	var refresh_rate := roundi(DisplayServer.screen_get_refresh_rate(screen))

	return {
		"width": size.x,
		"height": size.y,
		"refresh_rate": refresh_rate,
		"device_name": _active_device_name
	}


func _set_monitor_resolution(resolution: Dictionary) -> bool:
	if resolution.is_empty() or _active_device_name.is_empty():
		return false

	if not resolution.has("width") or not resolution.has("height") or not resolution.has("refresh_rate"):
		return false

	var result := _resolution_manager.set_resolution(
		_active_device_name,
		int(resolution["width"]),
		int(resolution["height"]),
		int(resolution["refresh_rate"])
	)

	if result != 0:
		push_warning("SettingsManager: Failed to change display resolution. Error: " + str(result))
		return false

	return true


func _restore_monitor_resolution() -> bool:
	if _active_device_name.is_empty():
		return false

	var result := _resolution_manager.restore_resolution(_active_device_name)

	if result != 0:
		push_warning("SettingsManager: Failed to restore display resolution. Error: " + str(result))
		return false

	return true


func set_display_mode(mode: String) -> void:
	if mode not in [MODE_WINDOWED, MODE_BORDERLESS, MODE_FULLSCREEN]:
		push_warning("SettingsManager: Invalid display mode: " + mode)
		return

	if _preview_active:
		return

	if display_mode == MODE_FULLSCREEN and mode != MODE_FULLSCREEN:
		_restore_monitor_resolution()

	if mode == MODE_FULLSCREEN:
		if fullscreen_resolution.is_empty():
			fullscreen_resolution = _get_current_fullscreen_resolution()

		if not _set_monitor_resolution(fullscreen_resolution):
			return

	display_mode = mode
	await _apply_display_mode(mode)

	_save_settings()
	display_settings_changed.emit()


func set_windowed_resolution(resolution: Vector2i) -> void:
	var available := get_available_windowed_resolutions()

	if resolution not in available:
		push_warning("SettingsManager: Unsupported windowed resolution: " + str(resolution))
		return

	windowed_resolution = resolution

	if display_mode == MODE_WINDOWED and not _preview_active:
		await _apply_display_mode(MODE_WINDOWED)

	_save_settings()


func begin_display_preview(mode: String, resolution: Dictionary = {}) -> bool:
	if _preview_active:
		return false

	if mode not in [MODE_WINDOWED, MODE_BORDERLESS, MODE_FULLSCREEN]:
		return false

	if mode == MODE_FULLSCREEN:
		if resolution.is_empty():
			return false

		if resolution.get("device_name", "") != _active_device_name:
			return false

	_previous_mode = display_mode
	_previous_windowed_resolution = windowed_resolution
	_previous_fullscreen_resolution = fullscreen_resolution.duplicate(true)

	_pending_preview_mode = mode
	_preview_active = true

	if display_mode == MODE_FULLSCREEN and mode != MODE_FULLSCREEN:
		if not _restore_monitor_resolution():
			_preview_active = false
			return false

	if mode == MODE_FULLSCREEN:
		if not _set_monitor_resolution(resolution):
			if _previous_mode == MODE_FULLSCREEN:
				_set_monitor_resolution(_previous_fullscreen_resolution)

			_preview_active = false
			return false

		fullscreen_resolution = resolution.duplicate(true)

	if mode == MODE_WINDOWED:
		if resolution.has("width") and resolution.has("height"):
			windowed_resolution = Vector2i(
				int(resolution["width"]),
				int(resolution["height"])
			)

	await _apply_display_mode(mode)

	_preview_timer.start(PREVIEW_DURATION)
	preview_started.emit(PREVIEW_DURATION)

	return true


func confirm_display_preview() -> void:
	if not _preview_active:
		return

	_preview_timer.stop()

	display_mode = _pending_preview_mode
	_preview_active = false

	_save_settings()
	display_settings_changed.emit()
	preview_finished.emit(true)


func cancel_display_preview() -> void:
	if not _preview_active:
		return

	_preview_timer.stop()

	if _previous_mode == MODE_FULLSCREEN:
		if _pending_preview_mode == MODE_FULLSCREEN:
			_set_monitor_resolution(_previous_fullscreen_resolution)
		else:
			_set_monitor_resolution(_previous_fullscreen_resolution)
	else:
		if _pending_preview_mode == MODE_FULLSCREEN:
			_restore_monitor_resolution()

	display_mode = _previous_mode
	windowed_resolution = _previous_windowed_resolution
	fullscreen_resolution = _previous_fullscreen_resolution.duplicate(true)

	await _apply_display_mode(display_mode)

	_preview_active = false
	display_settings_changed.emit()
	preview_finished.emit(false)


func _apply_display_mode(mode: String) -> void:
	var window := get_window()

	var screen := get_active_screen()
	var screen_size := DisplayServer.screen_get_size(screen)
	var screen_position := DisplayServer.screen_get_position(screen)

	match mode:
		MODE_WINDOWED:
			var available := get_available_windowed_resolutions()

			if windowed_resolution not in available:
				windowed_resolution = _get_default_windowed_resolution()

			window.borderless = false
			window.mode = Window.MODE_WINDOWED

			var mode_changed := false

			for frame in range(60):
				await get_tree().process_frame

				if window.mode == Window.MODE_WINDOWED:
					mode_changed = true
					break

			if not mode_changed:
				push_warning("SettingsManager: Failed to enter Windowed mode.")
				return

			window.size = windowed_resolution

			for frame in range(30):
				await get_tree().process_frame

				if window.size == windowed_resolution:
					break

			window.position = screen_position + (
				(screen_size - windowed_resolution) / 2
			)

		MODE_BORDERLESS:
			window.borderless = false
			window.mode = Window.MODE_FULLSCREEN

		MODE_FULLSCREEN:
			window.borderless = false
			window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN

	await get_tree().process_frame


func _get_default_windowed_resolution() -> Vector2i:
	var available := get_available_windowed_resolutions()

	if DEFAULT_WINDOWED_RESOLUTION in available:
		return DEFAULT_WINDOWED_RESOLUTION

	if available.is_empty():
		return Vector2i.ZERO

	return available[available.size() - 1]


func _save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("display", "mode", display_mode)
	config.set_value("display", "windowed_resolution", windowed_resolution)
	config.set_value("display", "fullscreen_resolution", fullscreen_resolution)

	var error := config.save(CONFIG_PATH)

	if error != OK:
		push_warning("SettingsManager: Failed to save settings. Error: " + str(error))


func _load_settings() -> void:
	var config := ConfigFile.new()

	var error := config.load(CONFIG_PATH)

	if error != OK:
		display_mode = MODE_BORDERLESS
		windowed_resolution = DEFAULT_WINDOWED_RESOLUTION
		fullscreen_resolution = {}
		return

	var saved_mode = config.get_value("display", "mode", MODE_BORDERLESS)

	if saved_mode in [MODE_WINDOWED, MODE_BORDERLESS, MODE_FULLSCREEN]:
		display_mode = saved_mode
	else:
		display_mode = MODE_BORDERLESS

	var saved_resolution = config.get_value(
		"display",
		"windowed_resolution",
		DEFAULT_WINDOWED_RESOLUTION
	)

	if saved_resolution is Vector2i and saved_resolution.x > 0 and saved_resolution.y > 0:
		windowed_resolution = saved_resolution
	else:
		windowed_resolution = DEFAULT_WINDOWED_RESOLUTION

	var saved_fullscreen = config.get_value("display", "fullscreen_resolution", {})

	if saved_fullscreen is Dictionary:
		fullscreen_resolution = saved_fullscreen.duplicate(true)
	else:
		fullscreen_resolution = {}
		
