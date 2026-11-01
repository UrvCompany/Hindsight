
extends Node

const SAVE_PATH: String = "user://savegame.json"


var resume_dialogue: String = ""
var checkpoint_locked: bool = false
var _last_snapshot: String = ""

func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = 1.0
	timer.timeout.connect(_autosave)
	add_child(timer)
	timer.start()

func _autosave() -> void:
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path.begins_with("res://Scene/Level1/") and not checkpoint_locked:
		save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_autosave()

func new_game() -> bool:
	# Capture old state so a failed write cannot erase the active session.
	var previous := [SceneStateGlobal.STAGE, SceneStateGlobal.CURRENT_LEVEL, SceneStateGlobal.current_scene,
		SceneStateGlobal.collected_words.duplicate(), SceneStateGlobal.flags.duplicate(true),
		SceneStateGlobal.items.duplicate(true), SceneStateGlobal.met_characters.duplicate(true),
		SceneStateGlobal.completed_quests.duplicate(true), resume_dialogue, checkpoint_locked]
	SceneStateGlobal.STAGE = 0
	SceneStateGlobal.CURRENT_LEVEL = 0
	SceneStateGlobal.current_scene = SceneStateGlobal.HOME_SCENE[0]
	SceneStateGlobal.current_state = SceneStateGlobal.State.EXPLORATION
	SceneStateGlobal.collected_words = []
	SceneStateGlobal.flags = {}
	SceneStateGlobal.items = {}
	SceneStateGlobal.met_characters = {}
	SceneStateGlobal.completed_quests = {}
	resume_dialogue = ""
	checkpoint_locked = false
	_last_snapshot = ""
	if save_game():
		return true
	SceneStateGlobal.STAGE = previous[0]
	SceneStateGlobal.CURRENT_LEVEL = previous[1]
	SceneStateGlobal.current_scene = previous[2]
	SceneStateGlobal.collected_words.assign(previous[3])
	SceneStateGlobal.flags = previous[4]
	SceneStateGlobal.items = previous[5]
	SceneStateGlobal.met_characters = previous[6]
	SceneStateGlobal.completed_quests = previous[7]
	resume_dialogue = previous[8]
	checkpoint_locked = previous[9]
	return false

func save_final_choice(dialogue: DialogueData) -> bool:
	resume_dialogue = dialogue.resource_path
	checkpoint_locked = false
	var saved := save_game()
	checkpoint_locked = saved
	return saved

func restore_dialogue(path: String) -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	if not path.is_empty() and ResourceLoader.exists(path):
		var dialogue := load(path) as DialogueData
		if dialogue != null:
			SupportingSceneManager.open(load("res://UI/DialogueBox/DialogueBox.tscn"), dialogue)
	resume_dialogue = ""
	checkpoint_locked = false

func save_game() -> bool:
	if checkpoint_locked:
		return true
	var scene := get_tree().current_scene
	if scene != null and scene.scene_file_path.begins_with("res://Scene/Level1/"):
		SceneStateGlobal.current_scene = scene.scene_file_path

	var save_data: Dictionary = {
		"version": 1,
		"resume_dialogue": resume_dialogue,
		"stage": SceneStateGlobal.STAGE,
		"current_level": SceneStateGlobal.CURRENT_LEVEL,
		"current_scene": SceneStateGlobal.current_scene,
		"collected_words": SceneStateGlobal.collected_words,
		"flags": SceneStateGlobal.flags,
		"items": SceneStateGlobal.items,
		"met_characters": SceneStateGlobal.met_characters,
		"completed_quests": SceneStateGlobal.completed_quests
	}

	var serialized := JSON.stringify(save_data, "\t")
	if serialized == _last_snapshot and has_save():
		return true
	var file: FileAccess = FileAccess.open(SAVE_PATH + ".tmp", FileAccess.WRITE)

	if file == null:
		push_error("Не удалось открыть файл сохранения")
		return false

	file.store_string(serialized)
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		return false
	var rename_error := DirAccess.rename_absolute(ProjectSettings.globalize_path(SAVE_PATH + ".tmp"), ProjectSettings.globalize_path(SAVE_PATH))
	if rename_error != OK:
		push_error("Не удалось заменить сохранение: " + error_string(rename_error))
		return false
	_last_snapshot = serialized
	
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

	resume_dialogue = str(data.get("resume_dialogue", ""))
	checkpoint_locked = false
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
