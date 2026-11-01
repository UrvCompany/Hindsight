
extends Control
class_name DialogueBox

var dialogue_data: DialogueData
var current_line_index: int = 0
var default_rects: Dictionary = {}

@onready var name_label: Label = $Panel/Name
@onready var portrait_rect: TextureRect = $Panel/Portrait
@onready var text_label: Label = $Panel/Text
@onready var next_button: Button = $Panel/NextButton
@onready var choice_button_1: Button = $Panel/ChoiceButton1
@onready var choice_button_2: Button = $Panel/ChoiceButton2


func _ready() -> void:
	for control: Control in [$Panel, text_label, next_button, choice_button_1, choice_button_2]:
		default_rects[control] = Rect2(control.position, control.size)
	next_button.pressed.connect(_on_next_button_pressed)
	choice_button_1.pressed.connect(_on_choice_pressed.bind(0))
	choice_button_2.pressed.connect(_on_choice_pressed.bind(1))

	_hide_choices()


func setup(data: Variant) -> void:
	if not data is DialogueData:
		push_error("DialogueBox ожидал получить DialogueData")
		return

	for control: Control in default_rects:
		var rect: Rect2 = default_rects[control]
		control.position = rect.position
		control.size = rect.size

	dialogue_data = data as DialogueData
	current_line_index = 0
	_hide_choices()

	if dialogue_data.lines.is_empty():
		text_label.text = ""
		_show_choices()
		return

	_show_current_line()


func _show_current_line() -> void:
	if dialogue_data == null:
		return

	if current_line_index < 0 or current_line_index >= dialogue_data.lines.size():
		return

	var line: DialogueLine = dialogue_data.lines[current_line_index]

	if line == null:
		push_warning("Обнаружена пустая реплика")
		return

	var speaker: CharacterData = line.speaker

	if speaker == null:
		speaker = dialogue_data.character

	if speaker != null:
		name_label.text = speaker.get_display_name()
	else:
		name_label.text = ""

	if line.portrait != null:
		portrait_rect.texture = line.portrait
	elif speaker != null:
		portrait_rect.texture = speaker.portrait
	else:
		portrait_rect.texture = null

	text_label.text = line.text

	for word: String in line.granted_words:
		if not word.is_empty() and not SceneStateGlobal.collected_words.has(word):
			SupportingSceneManager.word_collected.emit(word)

	if current_line_index == dialogue_data.lines.size() - 1 and not dialogue_data.choices.is_empty():
		_show_choices()
	else:
		next_button.show()


func _on_next_button_pressed() -> void:
	if dialogue_data == null:
		return

	current_line_index += 1

	if current_line_index >= dialogue_data.lines.size():
		_show_choices()
		return

	_show_current_line()


func _show_choices() -> void:
	next_button.hide()
	_hide_choices()

	if dialogue_data == null:
		return

	if dialogue_data.choices.is_empty():
		_finish_dialogue()
		return

	var needs_wrapping := false
	for choice: DialogueChoice in dialogue_data.choices:
		if choice != null and choice.text.length() > 100:
			needs_wrapping = true
	if needs_wrapping:
		$Panel.size = Vector2(1100, 500)
		text_label.size = Vector2(854, 150)
		for index in 2:
			var button: Button = choice_button_1 if index == 0 else choice_button_2
			button.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			button.position = Vector2(239, 190 + index * 150)
			button.size = Vector2(854, 140)

	if dialogue_data.choices.size() >= 1:
		var first_choice: DialogueChoice = dialogue_data.choices[0]

		if first_choice != null:
			choice_button_1.text = first_choice.text
			choice_button_1.show()

	if dialogue_data.choices.size() >= 2:
		var second_choice: DialogueChoice = dialogue_data.choices[1]

		if second_choice != null:
			choice_button_2.text = second_choice.text
			choice_button_2.show()


func _hide_choices() -> void:
	choice_button_1.hide()
	choice_button_2.hide()


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
	if dialogue_data.completion_ending != null:
		var ending_error := EndingManager.show_ending(dialogue_data.completion_ending)
		if ending_error == OK:
			SupportingSceneManager.close()
		else:
			push_error("Cannot open ending: " + error_string(ending_error))
		return

	if dialogue_data.completion_scene_path.is_empty():
		SupportingSceneManager.close()
		return

	var target_scene := load(dialogue_data.completion_scene_path) as PackedScene
	if target_scene == null:
		push_error("Cannot load dialogue ending: " + dialogue_data.completion_scene_path)
		return

	var error := get_tree().change_scene_to_packed(target_scene)
	if error != OK:
		push_error("Cannot open dialogue ending: " + error_string(error))
		return

	SupportingSceneManager.close()
