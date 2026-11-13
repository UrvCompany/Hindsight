
extends Control

signal dismissed

const SETTINGS_SCENE = preload("res://UI/Main_menu/Settings_Menu.tscn")

var error_label: Label
var _settings_instance: Control


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.03, 0.04, 0.72)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(520, 360)
	center.add_child(panel)

	var style := StyleBoxFlat.new()
	style.bg_color = Color("24272b")
	style.border_color = Color("bfa47b")
	style.set_border_width_all(2)
	style.set_content_margin_all(32)
	panel.add_theme_stylebox_override("panel", style)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	panel.add_child(column)

	var title := Label.new()
	title.text = "Пауза"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	column.add_child(title)

	_button(column, "Выбрать главу", _leave.bind("res://UI/Chapter_select/ChapterSelect.tscn"))
	_button(column, "Настройки", _open_settings)
	_button(column, "Выйти в главное меню", _leave.bind("res://UI/Main_menu/Main_menu.tscn"))

	error_label = Label.new()
	error_label.text = "Не удалось сохранить прогресс. Попробуйте ещё раз."
	error_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	error_label.custom_minimum_size.x = 440
	error_label.hide()
	column.add_child(error_label)


func _button(parent: Node, caption: String, action: Callable) -> void:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size.y = 58
	button.add_theme_font_size_override("font_size", 25)
	button.pressed.connect(action)
	parent.add_child(button)


func _open_settings() -> void:
	if is_instance_valid(_settings_instance):
		return

	_settings_instance = SETTINGS_SCENE.instantiate()
	get_parent().add_child(_settings_instance)

	_settings_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_settings_instance.open_as_overlay()
	_settings_instance.back_requested.connect(_on_settings_back)

	hide()


func _on_settings_back() -> void:
	if is_instance_valid(_settings_instance):
		_settings_instance.queue_free()

	_settings_instance = null
	show()


func _leave(path: String) -> void:
	if not SaveManager.save_game():
		error_label.show()
		return

	if get_tree().change_scene_to_file(path) != OK:
		error_label.text = "Не удалось открыть меню. Прогресс сохранён."
		error_label.show()
		return

	if is_instance_valid(_settings_instance):
		_settings_instance.queue_free()

	_settings_instance = null
	dismissed.emit()
