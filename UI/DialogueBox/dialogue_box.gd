extends Control
class_name DialogueBox

var dialogue_data: DialogueData
var current_line_index: int = 0

@onready var name_label: Label = $Panel/Name
@onready var portrait_rect: TextureRect = $Panel/Portrait
@onready var text_label: Label = $Panel/Text
@onready var next_button: Button = $Panel/NextButton


func _ready() -> void:
	next_button.pressed.connect(_on_next_button_pressed)


func setup(data: Variant) -> void:

	if not data is DialogueData:
		push_error("DialogueBox ожидал получить DialogueData")
		return

	dialogue_data = data as DialogueData
	current_line_index = 0

	if dialogue_data.lines.is_empty():
		push_warning("Диалог не содержит реплик")
		return

	_show_current_line()


func _show_current_line() -> void:
	if dialogue_data == null:
		return

	if current_line_index >= dialogue_data.lines.size():
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
	_update_next_button()


func _on_next_button_pressed() -> void:
	if dialogue_data == null:
		return

	current_line_index += 1

	if current_line_index >= dialogue_data.lines.size():
		SupportingSceneManager.close()
		return

	_show_current_line()
	
func _update_next_button() -> void:
	if dialogue_data == null:
		next_button.hide()
		return

	var total: int = dialogue_data.lines.size()

	# Для одной реплики кнопка не нужна.
	next_button.visible = total > 1

	if not next_button.visible:
		return

	if current_line_index == total - 1:
		next_button.text = "Завершить"
	else:
		next_button.text = "Далее"
