extends Node2D

const ANSWERS = preload("res://Data/CorrectAnswer.gd")
const PLAN_TEXT = preload("res://Scene/Thinking_scene/plan_text.gd")
const CARD_TEXTS := [
	["Какая глубина достижима?\n\nПлотный известняк начинается на глубине [url=slot_0]________[/url].", "Чем снабжают замок реки?\n\nДля наполнения водоёмов используется [url=slot_0]________[/url]."],
	["Куда ведёт путь?\n\nКонечная точка подземного хода — [url=slot_0]________[/url].", "Когда действовать?\n\nДля начала нападения выбрана [url=slot_0]________[/url]."]
]
var viewed_stage := 0
var page: Control
var tabs: HBoxContainer
var plan: RichTextLabel
var cards: Array[RichTextLabel] = []
var notes_status: Label
var status: Label
var advance: Button
const UI_FONT = preload("res://UI/Fonts/Montserrat_FontVariation_wght_400.tres")

func _ready() -> void:
	var desk := TextureRect.new()
	desk.texture = preload("res://Image/Thinking_screen/thinking_desk.png")
	desk.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	desk.size = Vector2(1920, 1080)
	desk.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(desk)
	move_child(desk, 0)
	tabs = HBoxContainer.new()
	tabs.position = Vector2(420, 26)
	tabs.add_theme_constant_override("separation", 18)
	add_child(tabs)
	for i in range(3):
		var button := _button(["I · Корона", "II · Восстание", "III · Вмешательство"][i], Vector2.ZERO, Vector2(340, 58))
		button.pressed.connect(_show.bind(i))
		tabs.add_child(button)
	tabs.visible = SceneStateGlobal.STAGE >= 2
	_show(mini(SceneStateGlobal.STAGE, 2))

func _paper(at: Vector2, dimensions: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = at
	panel.size = dimensions
	var style := StyleBoxFlat.new()
	style.bg_color = Color("dfd0ae")
	style.border_color = Color("ad9063")
	style.set_border_width_all(2)
	style.shadow_color = Color(0, 0, 0, 0.4)
	style.shadow_size = 12
	style.shadow_offset = Vector2(5, 8)
	panel.add_theme_stylebox_override("panel", style)
	page.add_child(panel)
	return panel

func _label(parent: Node, caption: String, at: Vector2, dimensions: Vector2, font_size: int, color := Color("3c3026")) -> Label:
	var label := Label.new()
	label.position = at
	label.size = dimensions
	label.text = caption
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_override("font", UI_FONT)
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func _button(caption: String, at: Vector2, dimensions: Vector2) -> Button:
	var button := Button.new()
	button.text = caption
	button.position = at
	button.custom_minimum_size = dimensions
	button.size = dimensions
	button.add_theme_font_size_override("font_size", 24)
	for state in ["normal", "hover", "pressed", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = Color("382b21") if state == "normal" else Color("59442e")
		if state == "disabled": style.bg_color = Color("514a40")
		style.border_color = Color("aa8b55")
		style.set_border_width_all(1)
		button.add_theme_stylebox_override(state, style)
	button.add_theme_color_override("font_color", Color("eee0bf"))
	return button

func _key() -> String:
	return "%d:%d" % [SceneStateGlobal.CURRENT_LEVEL, viewed_stage]

func _draft() -> Dictionary:
	return SceneStateGlobal.flags.get("thinking_drafts", {}).get(_key(), {})

func _text(parent: Node, source: String, at: Vector2, dimensions: Vector2, saved: Dictionary, font_size: int) -> RichTextLabel:
	var text := RichTextLabel.new()
	text.set_script(PLAN_TEXT)
	text.position = at
	text.size = dimensions
	text.add_theme_font_override("normal_font", UI_FONT)
	text.add_theme_font_size_override("normal_font_size", font_size)
	text.add_theme_color_override("default_color", Color("3c3026"))
	text.add_theme_constant_override("line_separation", 12)
	text.template = source
	text.words = saved.duplicate(true)
	text.read_only = viewed_stage < SceneStateGlobal.STAGE
	parent.add_child(text)
	text.refresh()
	text.edited.connect(_edited)
	return text

func _show(which: int) -> void:
	if SceneStateGlobal.STAGE < 2 and which != SceneStateGlobal.STAGE: return
	viewed_stage = which
	if is_instance_valid(page):
		remove_child(page)
		page.queue_free()
	cards.clear()
	page = Control.new()
	page.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(page)
	for i in range(3): tabs.get_child(i).disabled = i == which
	if which == 2:
		var heading := _label(page, "Определитесь с кем хотите поделиться информацией", Vector2(230, 280), Vector2(1460, 300), 62, Color("f3e6c9"))
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heading.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		return
	var left := _paper(Vector2(90, 110), Vector2(1060, 650))
	_label(left, "План короны" if which == 0 else "План революционеров", Vector2(48, 28), Vector2(960, 60), 38)
	_label(left, "Восстановите последовательность действий" if which == SceneStateGlobal.STAGE else "Собранный план · просмотр", Vector2(48, 92), Vector2(960, 38), 22, Color("7e694c"))
	var level: int = SceneStateGlobal.CURRENT_LEVEL
	var source: String = ANSWERS.Basic_plane.get(level, {}).get(which, "Материалы этой главы пока недоступны.")
	var lines := source.strip_edges().split("\n")
	for i in range(lines.size()): lines[i] = lines[i].strip_edges()
	if lines.size() > 1: lines.remove_at(0)
	var saved: Dictionary = _draft().get("plan", {}).duplicate(true)
	# Old saves have no draft; completed stages are already known.
	if saved.is_empty() and which < SceneStateGlobal.STAGE:
		var answers: Array = ANSWERS.CORRECT_ANSWERS.get(level, {}).get(which, [])
		for i in range(answers.size()): saved["slot_%d" % i] = answers[i]
	plan = _text(left, "\n\n".join(lines), Vector2(48, 155), Vector2(960, 365), saved, 29)
	status = _label(left, "Перетащите слова снизу в пропуски. Нажмите на слово, чтобы убрать его.", Vector2(48, 535), Vector2(960, 60), 20, Color("7e694c"))
	advance = _button("Проверить план", Vector2(48, 590), Vector2(420, 48))
	advance.pressed.connect(_check)
	left.add_child(advance)
	advance.visible = which == SceneStateGlobal.STAGE
	_label(page, "Рабочие заметки", Vector2(1210, 112), Vector2(600, 50), 30, Color("eee0bf"))
	for i in range(2):
		var card := _paper(Vector2(1210, 180 + i * 245), Vector2(610, 220))
		var card_source: String = CARD_TEXTS[which][i] if level == 0 else "Сопоставьте найденные свидетельства."
		cards.append(_text(card, card_source, Vector2(28, 22), Vector2(554, 177), _draft().get("card_%d" % i, {}), 25))
	notes_status = _label(page, "", Vector2(1210, 688), Vector2(600, 80), 24, Color("d2bd98"))
	_update_notes_status()

func _update_notes_status() -> void:
	if not is_instance_valid(notes_status) or viewed_stage >= 2: return
	notes_status.text = ""
	if SceneStateGlobal.CURRENT_LEVEL != 0: return
	var expected := [
		[{"slot_0": ANSWERS.DEPTH}, {"slot_0": ANSWERS.WATER}],
		[{"slot_0": ANSWERS.THRONE_ROOM}, {"slot_0": ANSWERS.NIGHT}]
	]
	var correct := true
	for i in range(cards.size()):
		for slot in expected[viewed_stage][i]:
			var word := str(cards[i].words.get(slot, ""))
			if word.is_empty(): return
			if word != expected[viewed_stage][i][slot]: correct = false
	notes_status.text = "Правильно. Рабочие заметки заполнены верно." if correct else "Неправильно. Проверьте рабочие заметки."
	notes_status.add_theme_color_override("font_color", Color("b6d79c") if correct else Color("f2a69a"))

func _edited() -> void:
	_update_notes_status()
	var drafts: Dictionary = SceneStateGlobal.flags.get("thinking_drafts", {})
	var data := {"plan": plan.words.duplicate(true)}
	for i in range(cards.size()): data["card_%d" % i] = cards[i].words.duplicate(true)
	drafts[_key()] = data
	SceneStateGlobal.flags["thinking_drafts"] = drafts
	status.text = "Черновик сохранён." if SaveManager.save_game() else "Не удалось сохранить черновик на диск."
	advance.text = "Проверить план"

func _is_correct() -> bool:
	var answers: Array = ANSWERS.CORRECT_ANSWERS.get(SceneStateGlobal.CURRENT_LEVEL, {}).get(viewed_stage, [])
	if answers.is_empty(): return false
	for i in range(answers.size()):
		if plan.words.get("slot_%d" % i, "") != answers[i]: return false
	return true

func _check() -> void:
	if viewed_stage != SceneStateGlobal.STAGE: return
	if not _is_correct():
		status.text = "План пока не сходится. Проверьте пропуски и сопоставьте свидетельства."
		return
	if advance.text != "Продолжить расследование":
		status.text = "План восстановлен. Можно продолжить расследование."
		advance.text = "Продолжить расследование"
		return
	_edited()
	var old_words = SceneStateGlobal.collected_words.duplicate()
	var old_scene: String = SceneStateGlobal.current_scene
	SceneStateGlobal.STAGE += 1
	SceneStateGlobal.collected_words = []
	SceneStateGlobal.current_scene = SceneStateGlobal.HOME_SCENE[SceneStateGlobal.CURRENT_LEVEL]
	if not SaveManager.save_game():
		SceneStateGlobal.STAGE -= 1
		SceneStateGlobal.collected_words.assign(old_words)
		SceneStateGlobal.current_scene = old_scene
		status.text = "Не удалось сохранить переход. Попробуйте ещё раз."
		return
	SceneStateGlobal.current_state = SceneStateGlobal.State.EXPLORATION
	get_tree().change_scene_to_file(SceneStateGlobal.current_scene)
