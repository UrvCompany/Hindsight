
extends Control

signal back_requested

@onready var display_mode_option: OptionButton = $MarginContainer/CenterContainer/VBoxContainer/DisplayModeRow/DisplayModeOption
@onready var resolution_option: OptionButton = $MarginContainer/CenterContainer/VBoxContainer/ResolutionRow/ResolutionOption
@onready var refresh_rate_option: OptionButton = $MarginContainer/CenterContainer/VBoxContainer/RefreshRateRow/RefreshRateOption
@onready var apply_button: Button = $MarginContainer/CenterContainer/VBoxContainer/ButtonsRow/ApplyButton
@onready var back_button: Button = $MarginContainer/CenterContainer/VBoxContainer/ButtonsRow/BackButton
@onready var refresh_rate_row: HBoxContainer = $MarginContainer/CenterContainer/VBoxContainer/RefreshRateRow

const DISPLAY_MODES := [
	{"name": "Windowed", "value": SettingsManager.MODE_WINDOWED},
	{"name": "Borderless", "value": SettingsManager.MODE_BORDERLESS},
	{"name": "Fullscreen", "value": SettingsManager.MODE_FULLSCREEN}
]

var _confirmation_dialog: ConfirmationDialog
var _countdown_timer: Timer
var _countdown := 15


func _ready() -> void:
	_populate_display_modes()
	_select_current_settings()

	display_mode_option.item_selected.connect(_on_display_mode_selected)
	resolution_option.item_selected.connect(_on_resolution_selected)
	apply_button.pressed.connect(_on_apply_pressed)
	back_button.pressed.connect(_on_back_pressed)

	_create_confirmation_dialog()

	SettingsManager.preview_started.connect(_on_preview_started)
	SettingsManager.preview_finished.connect(_on_preview_finished)


func _create_confirmation_dialog() -> void:
	_confirmation_dialog = ConfirmationDialog.new()
	_confirmation_dialog.title = "Confirm display settings"
	_confirmation_dialog.dialog_text = "Keep these display settings?"
	_confirmation_dialog.confirmed.connect(_on_preview_confirmed)
	_confirmation_dialog.canceled.connect(_on_preview_cancelled)
	_confirmation_dialog.close_requested.connect(_on_preview_cancelled)
	add_child(_confirmation_dialog)

	_countdown_timer = Timer.new()
	_countdown_timer.wait_time = 1.0
	_countdown_timer.timeout.connect(_on_countdown_tick)
	add_child(_countdown_timer)


func _populate_display_modes() -> void:
	display_mode_option.clear()

	for i in range(DISPLAY_MODES.size()):
		display_mode_option.add_item(DISPLAY_MODES[i]["name"], i)


func _select_current_settings() -> void:
	for i in range(DISPLAY_MODES.size()):
		if DISPLAY_MODES[i]["value"] == SettingsManager.display_mode:
			display_mode_option.select(i)
			break

	_update_resolution_option()


func _on_display_mode_selected(_index: int) -> void:
	_update_resolution_option()


func _on_resolution_selected(_index: int) -> void:
	if _get_selected_mode() == SettingsManager.MODE_FULLSCREEN:
		_update_refresh_rate_option()


func _update_resolution_option() -> void:
	refresh_rate_row.visible = _get_selected_mode() == SettingsManager.MODE_FULLSCREEN
	resolution_option.clear()

	var selected_mode := _get_selected_mode()

	match selected_mode:
		SettingsManager.MODE_WINDOWED:
			resolution_option.disabled = false
			refresh_rate_option.disabled = true
			refresh_rate_option.clear()

			var resolutions := SettingsManager.get_available_windowed_resolutions()

			for resolution in resolutions:
				var index := resolution_option.item_count

				resolution_option.add_item("%d × %d" % [
					resolution.x,
					resolution.y
				])

				resolution_option.set_item_metadata(index, {
					"width": resolution.x,
					"height": resolution.y
				})

				if resolution == SettingsManager.windowed_resolution:
					resolution_option.select(index)

		SettingsManager.MODE_BORDERLESS:
			resolution_option.disabled = true
			refresh_rate_option.disabled = true
			refresh_rate_option.clear()

			var resolution := SettingsManager.get_current_display_resolution()

			resolution_option.add_item("%d × %d" % [
				resolution.x,
				resolution.y
			])
			resolution_option.select(0)

		SettingsManager.MODE_FULLSCREEN:
			resolution_option.disabled = false
			refresh_rate_option.disabled = false

			var resolutions := SettingsManager.get_available_fullscreen_resolutions()

			for resolution in resolutions:
				var index := resolution_option.item_count

				resolution_option.add_item("%d × %d" % [
					resolution["width"],
					resolution["height"]
				])

				resolution_option.set_item_metadata(index, resolution)

				if (
					resolution["width"] == SettingsManager.fullscreen_resolution.get("width", -1)
					and resolution["height"] == SettingsManager.fullscreen_resolution.get("height", -1)
				):
					resolution_option.select(index)

			if resolution_option.selected < 0 and resolution_option.item_count > 0:
				resolution_option.select(0)

			_update_refresh_rate_option()


func _update_refresh_rate_option() -> void:
	refresh_rate_option.clear()

	if _get_selected_mode() != SettingsManager.MODE_FULLSCREEN:
		refresh_rate_option.disabled = true
		return

	var resolution := _get_selected_resolution()

	if resolution.is_empty():
		refresh_rate_option.disabled = true
		return

	var rates := SettingsManager.get_available_fullscreen_refresh_rates(
		int(resolution["width"]),
		int(resolution["height"])
	)

	refresh_rate_option.disabled = rates.is_empty()

	var saved_rate := int(
		SettingsManager.fullscreen_resolution.get("refresh_rate", -1)
	)

	for i in range(rates.size()):
		refresh_rate_option.add_item("%d Hz" % rates[i])
		refresh_rate_option.set_item_metadata(i, rates[i])

		if rates[i] == saved_rate:
			refresh_rate_option.select(i)

	if refresh_rate_option.selected < 0 and not rates.is_empty():
		refresh_rate_option.select(rates.size() - 1)


func _get_selected_mode() -> String:
	var index := display_mode_option.selected

	if index < 0 or index >= DISPLAY_MODES.size():
		return SettingsManager.MODE_WINDOWED

	return DISPLAY_MODES[index]["value"]


func _get_selected_resolution() -> Dictionary:
	var index := resolution_option.selected

	if index < 0:
		return {}

	var metadata = resolution_option.get_item_metadata(index)

	if metadata is Dictionary:
		return metadata

	return {}


func _get_selected_refresh_rate() -> int:
	var index := refresh_rate_option.selected

	if index < 0:
		return -1

	return int(refresh_rate_option.get_item_metadata(index))


func _has_display_settings_changed(
	selected_mode: String,
	selected_resolution: Dictionary
) -> bool:
	if selected_mode != SettingsManager.display_mode:
		return true

	match selected_mode:
		SettingsManager.MODE_WINDOWED:
			var resolution := Vector2i(
				int(selected_resolution["width"]),
				int(selected_resolution["height"])
			)
			return resolution != SettingsManager.windowed_resolution

		SettingsManager.MODE_BORDERLESS:
			return false

		SettingsManager.MODE_FULLSCREEN:
			var current := SettingsManager.fullscreen_resolution
			var selected_rate := _get_selected_refresh_rate()

			return (
				int(selected_resolution["width"]) != int(current.get("width", -1))
				or int(selected_resolution["height"]) != int(current.get("height", -1))
				or selected_rate != int(current.get("refresh_rate", -1))
			)

	return false


func _on_apply_pressed() -> void:
	var selected_mode := _get_selected_mode()
	var selected_resolution := _get_selected_resolution()

	if selected_mode == SettingsManager.MODE_FULLSCREEN:
		var refresh_rate := _get_selected_refresh_rate()

		if selected_resolution.is_empty() or refresh_rate < 0:
			return

		selected_resolution["refresh_rate"] = refresh_rate
		selected_resolution["device_name"] = SettingsManager._active_device_name

	elif selected_mode == SettingsManager.MODE_WINDOWED:
		if selected_resolution.is_empty():
			return

	if not _has_display_settings_changed(selected_mode, selected_resolution):
		return

	apply_button.disabled = true

	var success := await SettingsManager.begin_display_preview(
		selected_mode,
		selected_resolution
	)

	apply_button.disabled = false

	if not success:
		push_warning("Settings_Menu: Failed to apply display preview.")


func _on_preview_started(seconds: int) -> void:
	_countdown = seconds
	_update_confirmation_text()
	_countdown_timer.start()
	_confirmation_dialog.popup_centered()


func _update_confirmation_text() -> void:
	_confirmation_dialog.dialog_text = (
		"Keep these display settings?\n\n"
		+ "Reverting in %d seconds." % _countdown
	)


func _on_countdown_tick() -> void:
	_countdown -= 1

	if _countdown <= 0:
		_countdown_timer.stop()
		return

	_update_confirmation_text()


func _on_preview_confirmed() -> void:
	_countdown_timer.stop()
	SettingsManager.confirm_display_preview()


func _on_preview_cancelled() -> void:
	_countdown_timer.stop()
	SettingsManager.cancel_display_preview()


func _on_preview_finished(_accepted: bool) -> void:
	_countdown_timer.stop()

	if _confirmation_dialog.visible:
		_confirmation_dialog.hide()

	_select_current_settings()


func _on_back_pressed() -> void:
	if SettingsManager._preview_active:
		return

	get_tree().change_scene_to_file("res://UI/Main_menu/Main_menu.tscn")
