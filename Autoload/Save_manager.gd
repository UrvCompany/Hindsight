
extends Node

const SAVE_PATH: String = "user://savegame.json"


func save_game() -> bool:
	var save_data: Dictionary = {
		"version": 1,
		"stage": SceneStateGlobal.STAGE,
		"current_level": SceneStateGlobal.CURRENT_LEVEL,
		"current_scene": SceneStateGlobal.current_scene,
		"collected_words": SceneStateGlobal.collected_words,
		"flags": SceneStateGlobal.flags,
		"items": SceneStateGlobal.items,
		"met_characters": SceneStateGlobal.met_characters,
		"completed_quests": SceneStateGlobal.completed_quests
	}

	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.WRITE
	)

	if file == null:
		push_error("Не удалось открыть файл сохранения")
		return false

	file.store_string(JSON.stringify(save_data, "\t"))
	file.close()
	
	return true


func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		push_warning("Файл сохранения не найден")
		return false

	var file: FileAccess = FileAccess.open(
		SAVE_PATH,
		FileAccess.READ
	)

	if file == null:
		push_error("Не удалось открыть файл сохранения")
		return false

	var json_text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(json_text)

	if not parsed is Dictionary:
		push_error("Файл сохранения повреждён")
		return false

	var data: Dictionary = parsed

	if not data.has("version") or data["version"] != 1:
		push_error("Неизвестная версия сохранения")
		return false

	# Восстанавливаем состояние игры.
	SceneStateGlobal.STAGE = int(data.get("stage", 0))
	SceneStateGlobal.CURRENT_LEVEL = int(data.get("current_level", 0))
	SceneStateGlobal.current_scene = str(data.get("current_scene", ""))

	# Восстанавливаем типизированный массив слов.
	var words: Array[String] = []

	for word: Variant in data.get("collected_words", []):
		if word is String:
			words.append(word)

	SceneStateGlobal.collected_words = words

	# Восстанавливаем словари.
	SceneStateGlobal.flags = _get_dictionary(data, "flags")
	SceneStateGlobal.items = _get_dictionary(data, "items")
	SceneStateGlobal.met_characters = _get_dictionary(
		data,
        "met_characters"
		)
		
	SceneStateGlobal.completed_quests = _get_dictionary(
		data,
        "completed_quests"
		)

	# После загрузки начинаем с обычного игрового режима.
	SceneStateGlobal.current_state = (
		SceneStateGlobal.State.EXPLORATION
	)


	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func delete_save() -> bool:
	if not has_save():
		return true

	var error: Error = DirAccess.remove_absolute(
		ProjectSettings.globalize_path(SAVE_PATH)
	)

	if error != OK:
		push_error("Не удалось удалить сохранение")
		return false

	return true


func _get_dictionary(
	data: Dictionary,
	key: String
	) -> Dictionary:
		
	var value: Variant = data.get(key, {})

	if value is Dictionary:
		return value

	return {}
