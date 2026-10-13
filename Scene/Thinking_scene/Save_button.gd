
extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	print("=== СОХРАНЕНИЕ ИГРЫ ===")

	# Сохраняем реальные данные игры.
	var saved: bool = SaveManager.save_game()

	if saved:
		print("Игра успешно сохранена.")
		print("Уровень: ", SceneStateGlobal.CURRENT_LEVEL)
		print("Этап: ", SceneStateGlobal.STAGE)
		print("Сцена: ", SceneStateGlobal.current_scene)
		print(
			"Путь к файлу: ",
			ProjectSettings.globalize_path(SaveManager.SAVE_PATH)
		)
	else:
		push_error("Не удалось сохранить игру.")

	print("=== СОХРАНЕНИЕ ЗАВЕРШЕНО ===")
