
extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)

	# Отключаем кнопку, если сохранения нет.
	disabled = not SaveManager.has_save()


func _on_pressed() -> void:

	# Загружаем сохранённые данные.
	var loaded: bool = SaveManager.load_game()

	if not loaded:
		push_error("Не удалось загрузить сохранение.")
		return

	# Получаем сцену, на которой сохранился игрок.
	var scene_path: String = SceneStateGlobal.current_scene

	if scene_path.is_empty():
		push_error("В сохранении не указан путь к игровой сцене.")
		return

	# Проверяем, существует ли файл сцены.
	if not ResourceLoader.exists(scene_path):
		push_error("Сохранённая сцена не найдена: " + scene_path)
		return

	# Открываем сохранённую сцену.
	var error: Error = get_tree().change_scene_to_file(scene_path)

	if error != OK:
		push_error("Не удалось открыть сцену: " + scene_path)
		return

	print("Продолжаем игру.")
	print("Уровень: ", SceneStateGlobal.CURRENT_LEVEL)
	print("Этап: ", SceneStateGlobal.STAGE)
	print("Сцена: ", scene_path)
