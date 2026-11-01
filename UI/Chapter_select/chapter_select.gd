extends Control

const MENU = "res://UI/Main_menu/Main_menu.tscn"
var status: Label

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("171c22")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	for side in ["left", "right"]:
		margin.add_theme_constant_override("margin_" + side, 110)
	for side in ["top", "bottom"]:
		margin.add_theme_constant_override("margin_" + side, 65)
	add_child(margin)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 25)
	margin.add_child(column)
	_label(column, "H I N D S I G H T", 20, Color("bfa47b"))
	_label(column, "Выбор главы", 48, Color("eee7d8"))
	_label(column, "У каждой истории есть другая сторона", 22, Color("a8aaa9"))
	var spacer := Control.new()
	spacer.custom_minimum_size.y = 22
	column.add_child(spacer)
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 32)
	column.add_child(row)
	_card(row, "Глава I", "Вилы против короны", "res://Image/Interface/chapter_1.png", true)
	_card(row, "Глава II", "Скоро", "res://Image/Scenes/General_plain.png", false)
	_card(row, "Глава III", "Скоро", "res://Image/Scenes/village_clear.png", false)
	status = _label(column, "", 22, Color("c3beb3"))
	status.hide()
	var back := Button.new()
	back.text = "Назад в меню"
	back.custom_minimum_size = Vector2(260, 58)
	back.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back.add_theme_font_size_override("font_size", 24)
	back.pressed.connect(func(): get_tree().change_scene_to_file(MENU))
	column.add_child(back)

func _label(parent: Node, caption: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = caption
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _card(parent: Node, chapter: String, title: String, art: String, available: bool) -> void:
	var button := Button.new()
	button.name = "Chapter1" if available else chapter
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.disabled = not available
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND if available else Control.CURSOR_ARROW
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var box := StyleBoxFlat.new()
		box.bg_color = Color("30302e") if available else Color("24272b")
		box.border_color = Color("e8c573") if state in ["hover", "pressed", "focus"] else Color("454647")
		box.set_border_width_all(2)
		button.add_theme_stylebox_override(state, box)
	parent.add_child(button)
	var content := VBoxContainer.new()
	content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	content.offset_left = 4
	content.offset_top = 4
	content.offset_right = -4
	content.offset_bottom = -4
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_theme_constant_override("separation", 0)
	button.add_child(content)
	var image := TextureRect.new()
	image.texture = load(art)
	image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	image.size_flags_vertical = Control.SIZE_EXPAND_FILL
	image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if not available:
		image.modulate = Color(0.32, 0.34, 0.37)
	content.add_child(image)
	var subtitle := _label(content, chapter, 22, Color("c2b59a") if available else Color("898c90"))
	subtitle.custom_minimum_size.y = 46
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title_label := _label(content, title, 30, Color("eee7d8") if available else Color("a1a3a5"))
	title_label.custom_minimum_size.y = 66
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	for label in [subtitle, title_label]:
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if available:
		button.pressed.connect(_start_chapter)

func _start_chapter() -> void:
	if not SaveManager.load_game():
		status.show()
		status.text = "Не удалось загрузить прогресс. Вернитесь в меню и попробуйте снова."
		return
	var path: String = SceneStateGlobal.current_scene
	if path.is_empty():
		path = SceneStateGlobal.HOME_SCENE[0]
	if not ResourceLoader.exists(path):
		status.show()
		status.text = "Сохранённая сцена недоступна."
		return
	var dialogue_path: String = SaveManager.resume_dialogue
	if get_tree().change_scene_to_file(path) != OK:
		status.show()
		status.text = "Не удалось открыть главу."
		return
	SaveManager.restore_dialogue.call_deferred(dialogue_path)

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file(MENU)
