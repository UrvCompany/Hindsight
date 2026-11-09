
extends Control
class_name DialogueBox


const UI_THEME: Theme = preload("res://UI/Fonts/Fonts_theme.tres")
const PAPER_TEXTURE: Texture2D = preload("res://Image/Interface/dialogue_paper.svg")

const INK_COLOR := Color("33271d")
const MUTED_INK := Color("685540")
const BUTTON_COLOR := Color("c4ad83")
const BUTTON_HOVER := Color("b59a6d")
const BUTTON_PRESSED := Color("a58a60")

const PORTRAIT_SIZE := 176
const PANEL_TOP := 0.2
const PANEL_BOTTOM := 0.6


var dialogue_data: DialogueData

var _panel: PanelContainer
var _portrait: TextureRect
var _name_label: Label
var _lines_box: VBoxContainer
var _lines_scroll: ScrollContainer
var _next_button: Button
var _choices_box: VBoxContainer
var _choice_buttons: Array[Button] = []


func _ready() -> void:
	_build_interface()


func _build_interface() -> void:
	for child in get_children():
		child.free()

	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	# Основная бумажная панель.
	_panel = PanelContainer.new()
	_panel.name = "Panel"
	_panel.anchor_left = 0.07
	_panel.anchor_right = 0.93
	_panel.anchor_top = PANEL_TOP
	_panel.anchor_bottom = PANEL_BOTTOM
	_panel.custom_minimum_size.y = 360
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _make_paper_style())
	add_child(_panel)

	# Внутренние отступы панели.
	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	_panel.add_child(margin)

	var outer := HBoxContainer.new()
	outer.add_theme_constant_override("separation", 22)
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	outer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	margin.add_child(outer)

	# Портрет персонажа.
	_portrait = TextureRect.new()
	_portrait.name = "Portrait"
	_portrait.custom_minimum_size = Vector2(PORTRAIT_SIZE, PORTRAIT_SIZE)
	_portrait.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	outer.add_child(_portrait)

	# Правая часть: имя, реплики и кнопки.
	var content := VBoxContainer.new()
	content.name = "Content"
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 8)
	outer.add_child(content)

	_name_label = Label.new()
	_name_label.name = "Name"
	_name_label.add_theme_color_override("font_color", INK_COLOR)
	_name_label.add_theme_font_size_override("font_size", 23)
	_name_label.add_theme_font_override(
		"font",
		preload("res://UI/Fonts/Montserrat_FontVariation_wght_600.tres")
	)
	content.add_child(_name_label)

	var separator := ColorRect.new()
	separator.custom_minimum_size.y = 1
	separator.color = Color(0.30, 0.22, 0.15, 0.28)
	content.add_child(separator)

	# Область реплик с прокруткой при необходимости.
	_lines_scroll = ScrollContainer.new()
	_lines_scroll.name = "LinesScroll"
	_lines_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lines_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_lines_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_lines_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	content.add_child(_lines_scroll)

	_lines_box = VBoxContainer.new()
	_lines_box.name = "Lines"
	_lines_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lines_box.add_theme_constant_override("separation", 7)
	_lines_scroll.add_child(_lines_box)

	# Варианты ответа.
	_choices_box = VBoxContainer.new()
	_choices_box.name = "Choices"
	_choices_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_choices_box.add_theme_constant_override("separation", 7)
	content.add_child(_choices_box)

	# Кнопка продолжения.
	_next_button = Button.new()
	_next_button.name = "NextButton"
	_next_button.text = "Продолжить  →"
	_next_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	_next_button.add_theme_color_override("font_color", MUTED_INK)
	_next_button.add_theme_color_override("font_hover_color", INK_COLOR)
	_next_button.add_theme_font_size_override("font_size", 16)
	_next_button.add_theme_stylebox_override(
		"normal", _make_choice_style(Color(0, 0, 0, 0))
	)
	_next_button.add_theme_stylebox_override(
		"hover", _make_choice_style(Color(0.35, 0.25, 0.16, 0.12))
	)
	_next_button.pressed.connect(_on_next_button_pressed)
	content.add_child(_next_button)

	_choices_box.hide()
	_next_button.hide()


func _make_paper_style() -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = PAPER_TEXTURE

	style.texture_margin_left = 18
	style.texture_margin_right = 18
	style.texture_margin_top = 18
	style.texture_margin_bottom = 18

	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 16
	style.content_margin_bottom = 16

	return style


func _make_choice_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color

	style.border_width_left = 0
	style.border_width_right = 0
	style.border_width_top = 0
	style.border_width_bottom = 0

	style.content_margin_left = 12
	style.content_margin_right = 12
	style.content_margin_top = 8
	style.content_margin_bottom = 8

	return style


func _create_choice_button(index: int, choice: DialogueChoice) -> Button:
	var button := Button.new()
	button.name = "ChoiceButton%d" % (index + 1)
	button.text = choice.text
	button.custom_minimum_size.y = 42
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT

	button.add_theme_color_override("font_color", INK_COLOR)
	button.add_theme_color_override("font_hover_color", INK_COLOR)
	button.add_theme_font_size_override("font_size", 16)

	button.add_theme_stylebox_override(
		"normal", _make_choice_style(BUTTON_COLOR)
	)
	button.add_theme_stylebox_override(
		"hover", _make_choice_style(BUTTON_HOVER)
	)
	button.add_theme_stylebox_override(
		"pressed", _make_choice_style(BUTTON_PRESSED)
	)

	button.pressed.connect(_on_choice_pressed.bind(index))

	return button


func setup(data: Variant) -> void:
	if not data is DialogueData:
		push_error("DialogueBox ожидал получить DialogueData")
		return

	dialogue_data = data as DialogueData
	_render_dialogue()


func _render_dialogue() -> void:
	if dialogue_data == null:
		return

	for child in _lines_box.get_children():
		child.queue_free()

	for child in _choices_box.get_children():
		child.queue_free()

	_choice_buttons.clear()

	_name_label.text = ""
	_portrait.texture = null
	_choices_box.hide()
	_next_button.hide()

	var primary_speaker: CharacterData = dialogue_data.character

	# Определяем имя и портрет основного персонажа.
	for line: DialogueLine in dialogue_data.lines:
		if line == null:
			continue

		var speaker := line.speaker if line.speaker != null else dialogue_data.character

		if primary_speaker == null and speaker != null:
			primary_speaker = speaker

		if _portrait.texture == null:
			if line.portrait != null:
				_portrait.texture = line.portrait
			elif speaker != null:
				_portrait.texture = speaker.portrait

	if primary_speaker != null:
		_name_label.text = primary_speaker.get_display_name()

	# Отображаем все реплики текущего DialogueData.
	for line: DialogueLine in dialogue_data.lines:
		if line == null:
			push_warning("Обнаружена пустая реплика")
			continue

		var speaker := line.speaker if line.speaker != null else dialogue_data.character

		var body := Label.new()
		body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		body.size_flags_vertical = Control.SIZE_SHRINK_BEGIN

		body.add_theme_color_override("font_color", INK_COLOR)
		body.add_theme_font_size_override("font_size", 17)
		body.add_theme_font_override(
			"font",
			preload("res://UI/Fonts/Montserrat_FontVariation_wght_400.tres")
		)

		body.text = line.text

		if speaker != null and primary_speaker != null and speaker != primary_speaker:
			body.text = "%s: %s" % [
				speaker.get_display_name(),
				line.text
			]

		_lines_box.add_child(body)

		# Выдаём слова, если они ещё не были получены.
		for word: String in line.granted_words:
			if not word.is_empty() and not SceneStateGlobal.collected_words.has(word):
				SupportingSceneManager.word_collected.emit(word)

	# Создаём все варианты ответа.
	if dialogue_data.choices.size() > 0:
		_choices_box.show()

		for i in range(dialogue_data.choices.size()):
			var choice: DialogueChoice = dialogue_data.choices[i]

			if choice == null:
				continue

			var button := _create_choice_button(i, choice)
			_choices_box.add_child(button)
			_choice_buttons.append(button)
	else:
		_next_button.show()


func _on_next_button_pressed() -> void:
	_finish_dialogue()


func _on_choice_pressed(index: int) -> void:
	if dialogue_data == null:
		return

	if index < 0 or index >= dialogue_data.choices.size():
		return

	var choice: DialogueChoice = dialogue_data.choices[index]

	if choice == null:
		return

	if choice.next_dialogue != null:
		if choice.next_dialogue.completion_ending != null:
			if not SaveManager.save_final_choice(dialogue_data):
				push_error("Не удалось сохранить точку перед финальным решением")
				return

		setup(choice.next_dialogue)
	else:
		SupportingSceneManager.close()


func _finish_dialogue() -> void:
	if dialogue_data == null:
		return

	if dialogue_data.completion_ending != null:
		var ending_error := EndingManager.show_ending(
			dialogue_data.completion_ending
		)

		if ending_error == OK:
			SupportingSceneManager.close()
		else:
			push_error("Cannot open ending: " + error_string(ending_error))

		return

	if dialogue_data.completion_scene_path.is_empty():
		SupportingSceneManager.close()
		return

	var target_scene := load(
		dialogue_data.completion_scene_path
	) as PackedScene

	if target_scene == null:
		push_error(
			"Cannot load dialogue ending: " + dialogue_data.completion_scene_path
		)
		return

	var error := get_tree().change_scene_to_packed(target_scene)

	if error != OK:
		push_error("Cannot open dialogue ending: " + error_string(error))
		return

	SupportingSceneManager.close()
