extends RichTextLabel


var original_text := ""
var slot_words: Dictionary = {}
var correct_answers: Array[String] = []
var hovered_slot := ""

var loh: Sprite2D


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP

	meta_hover_started.connect(_on_meta_hover_started)
	meta_hover_ended.connect(_on_meta_hover_ended)


# ---------------------------------------------------------
# НАСТРОЙКА
# ---------------------------------------------------------

func setup_text(new_text: String) -> void:
	original_text = new_text
	text = original_text


func set_correct_answers(answers: Array[String]) -> void:
	correct_answers = answers


func set_loh(sprite: Sprite2D) -> void:
	loh = sprite


# ---------------------------------------------------------
# НАВЕДЕНИЕ НА ПРОПУСК
# ---------------------------------------------------------

func _on_meta_hover_started(meta: Variant) -> void:
	hovered_slot = str(meta)


func _on_meta_hover_ended(meta: Variant) -> void:
	if hovered_slot == str(meta):
		hovered_slot = ""


# ---------------------------------------------------------
# DRAG & DROP
# ---------------------------------------------------------

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return (
		data is String
		and not data.is_empty()
		and not hovered_slot.is_empty()
	)


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	slot_words[hovered_slot] = data

	update_text()

	# Проверяем только после заполнения всех слотов.
	if slot_words.size() == correct_answers.size():
		if check_answers():
			print("ПРАВИЛЬНО")
			loh.visible = false
		else:
			print("НЕПРАВИЛЬНО")
			loh.visible = true


# ---------------------------------------------------------
# ОБНОВЛЕНИЕ ТЕКСТА
# ---------------------------------------------------------

func update_text() -> void:
	var result := ""
	var last_position := 0

	var regex := RegEx.new()
	regex.compile("\\[url=(slot_\\d+)\\](.*?)\\[/url\\]")

	for match in regex.search_all(original_text):
		var start := match.get_start()
		var end := match.get_end()

		result += original_text.substr(
			last_position,
			start - last_position
		)

		var slot_id := match.get_string(1)

		if slot_words.has(slot_id):
			result += "[u][url=%s]%s[/url][/u]" % [
				slot_id,
				slot_words[slot_id]
			]
		else:
			result += match.get_string()

		last_position = end

	result += original_text.substr(last_position)

	text = result


# ---------------------------------------------------------
# ПРОВЕРКА ОТВЕТОВ
# ---------------------------------------------------------

func check_answers() -> bool:
	for i in correct_answers.size():
		var slot_id := "slot_%d" % i

		if not slot_words.has(slot_id):
			return false

		if slot_words[slot_id] != correct_answers[i]:
			return false

	return true
