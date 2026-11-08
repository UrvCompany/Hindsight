
extends Node

const INTRO = "res://UI/Intro/Intro.tscn"
const UI_THEME = preload("res://UI/Fonts/Fonts_theme.tres")

var confirmation: ConfirmationDialog
var quit_confirmation: ConfirmationDialog


func _ready() -> void:
	$LeftPanel/BoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$LeftPanel/BoxContainer/QuitButton.pressed.connect(_on_quit_button_pressed)

	confirmation = ConfirmationDialog.new()
	confirmation.theme = UI_THEME
	confirmation.transparent = true
	confirmation.title = "Начать новую игру?"
	confirmation.dialog_text = "Весь прогресс будет сброшен. Это действие нельзя отменить."
	confirmation.ok_button_text = "Сбросить и начать"
	confirmation.cancel_button_text = "Отмена"
	confirmation.min_size = Vector2i(680, 220)

	var confirmation_label = confirmation.get_label()
	confirmation_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirmation_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	confirmation_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	confirmation_label.add_theme_font_size_override("font_size", 20)

	confirmation.confirmed.connect(_confirm_new_game)
	add_child(confirmation)

	quit_confirmation = ConfirmationDialog.new()
	quit_confirmation.theme = UI_THEME
	quit_confirmation.transparent = true
	quit_confirmation.title = "Выход"
	quit_confirmation.dialog_text = "Вы действительно хотите выйти из игры?"
	quit_confirmation.ok_button_text = "Выйти"
	quit_confirmation.cancel_button_text = "Остаться"
	quit_confirmation.min_size = Vector2i(600, 190)

	var quit_label = quit_confirmation.get_label()
	quit_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	quit_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	quit_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	quit_label.add_theme_font_size_override("font_size", 26)

	quit_confirmation.confirmed.connect(_on_quit_confirmed)
	add_child(quit_confirmation)


func _on_quit_button_pressed() -> void:
	quit_confirmation.popup_centered()
	quit_confirmation.position.y += 35


func _on_quit_confirmed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	confirmation.popup_centered()


func _confirm_new_game() -> void:
	if SaveManager.new_game():
		get_tree().change_scene_to_file(INTRO)
	else:
		confirmation.dialog_text = "Не удалось сбросить сохранение. Проверьте доступ к файлам."
		confirmation.popup_centered()
