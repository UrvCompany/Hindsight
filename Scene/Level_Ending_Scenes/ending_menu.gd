extends CanvasLayer

const MAIN_MENU := "res://UI/Main_menu/Main_menu.tscn"
@export var ending_level: int = -1
var overlay: ColorRect
var panel: PanelContainer
var buttons: VBoxContainer

func _ready() -> void:
	layer = 100
	overlay = ColorRect.new()
	overlay.color = Color(0.03, 0.04, 0.06, 0.72)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(overlay)
	panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.offset_left = -250
	panel.offset_right = 250
	panel.offset_top = -180
	panel.offset_bottom = 180
	overlay.add_child(panel)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("202c36")
	style.border_color = Color("d7b766")
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 32
	style.content_margin_right = 32
	style.content_margin_top = 28
	style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", style)
	buttons = VBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	panel.add_child(buttons)
	_show_main_options()
	overlay.hide()

func _input(event: InputEvent) -> void:
	if overlay.visible:
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT or event.button_index == MOUSE_BUTTON_MIDDLE:
			overlay.show()
			get_viewport().set_input_as_handled()

func _clear_options() -> void:
	for child in buttons.get_children():
		buttons.remove_child(child)
		child.queue_free()

func _add_button(caption: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = caption
	button.custom_minimum_size = Vector2(436, 64)
	button.add_theme_font_size_override("font_size", 28)
	button.pressed.connect(action)
	buttons.add_child(button)
	return button

func _show_main_options() -> void:
	_clear_options()
	var level := ending_level if ending_level >= 0 else SceneStateGlobal.CURRENT_LEVEL
	var next_level := level + 1
	var next_button := _add_button("Следующий уровень", _start_chapter.bind(next_level))
	next_button.disabled = next_level >= SceneStateGlobal.HOME_SCENE.size()
	if next_button.disabled:
		next_button.tooltip_text = "Следующий уровень пока не добавлен"
	_add_button("Выбор главы", _show_chapters)
	_add_button("В главное меню", _open_main_menu)

func _show_chapters() -> void:
	get_tree().change_scene_to_file("res://UI/Chapter_select/ChapterSelect.tscn")


func _start_chapter(index: int) -> void:
	if index < 0 or index >= SceneStateGlobal.HOME_SCENE.size():
		return
	var target := load(SceneStateGlobal.HOME_SCENE[index]) as PackedScene
	if target == null:
		push_error("Не удалось загрузить главу")
		return
	var error := get_tree().change_scene_to_packed(target)
	if error != OK:
		push_error("Не удалось открыть главу: " + error_string(error))
		return
	SceneStateGlobal.CURRENT_LEVEL = index
	SceneStateGlobal.STAGE = 0
	SceneStateGlobal.current_state = SceneStateGlobal.State.EXPLORATION
	SceneStateGlobal.current_scene = SceneStateGlobal.HOME_SCENE[index]
	SceneStateGlobal.collected_words.clear()
	SceneStateGlobal.flags.clear()
	SceneStateGlobal.items.clear()
	SceneStateGlobal.met_characters.clear()
	SceneStateGlobal.completed_quests.clear()

func _open_main_menu() -> void:
	var error := get_tree().change_scene_to_file(MAIN_MENU)
	if error != OK:
		push_error("Не удалось открыть главное меню: " + error_string(error))
