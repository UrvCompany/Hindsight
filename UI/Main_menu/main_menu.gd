extends Node

const INTRO = "res://UI/Intro/Intro.tscn"
var confirmation: ConfirmationDialog

func _ready() -> void:
	$LeftPanel/BoxContainer/StartButton.pressed.connect(_on_start_pressed)
	confirmation = ConfirmationDialog.new()
	confirmation.theme = preload("res://UI/Fonts_theme.tres")
	confirmation.title = "Начать новую игру?"
	confirmation.dialog_text = "Весь прогресс будет сброшен. Это действие нельзя отменить."
	confirmation.ok_button_text = "Сбросить и начать"
	confirmation.cancel_button_text = "Отмена"
	confirmation.min_size = Vector2i(640, 200)
	confirmation.confirmed.connect(_confirm_new_game)
	add_child(confirmation)

func _on_start_pressed() -> void:
	confirmation.popup_centered()

func _confirm_new_game() -> void:
	if SaveManager.new_game():
		get_tree().change_scene_to_file(INTRO)
	else:
		confirmation.dialog_text = "Не удалось сбросить сохранение. Проверьте доступ к файлам."
		confirmation.popup_centered()
