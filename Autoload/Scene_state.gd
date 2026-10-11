
extends Node

enum State {
	EXPLORATION,
	THINKING,
	NOTES
}

# Текущий этап игры.
# 1 — первая стадия
# 2 — вторая стадия
# 3 — обе стадии
var STAGE: int = 0

# Текущий уровень.
var CURRENT_LEVEL: int = 0

# Текущее состояние игры.
var current_state: State = State.EXPLORATION

# Текущая игровая сцена.
var current_scene: String = ""

# Слова, которые игрок уже собрал.
var collected_words: Array[String] = []

# Главные сцены игры.
var HOME_SCENE: Array[String] = [
    "res://Scene/General/general.tscn"
]

# Сюжетные флаги.
var flags: Dictionary = {}

# Предметы игрока.
var items: Dictionary = {}

# Персонажи, с которыми игрок встречался.
var met_characters: Dictionary = {}

# Выполненные задания.
var completed_quests: Dictionary = {}


# ---------- ФЛАГИ ----------

func set_flag(flag_id: String, value: bool = true) -> void:
	flags[flag_id] = value


func has_flag(flag_id: String) -> bool:
	return flags.get(flag_id, false)


# ---------- ПРЕДМЕТЫ ----------

func add_item(item_id: String) -> void:
	items[item_id] = true


func remove_item(item_id: String) -> void:
	items.erase(item_id)


func has_item(item_id: String) -> bool:
	return items.has(item_id)


# ---------- ПЕРСОНАЖИ ----------

func mark_character_met(character_id: String) -> void:
	met_characters[character_id] = true


func has_met_character(character_id: String) -> bool:
	return met_characters.get(character_id, false)


# ---------- ЗАДАНИЯ ----------

func complete_quest(quest_id: String) -> void:
	completed_quests[quest_id] = true


func is_quest_completed(quest_id: String) -> bool:
	return completed_quests.get(quest_id, false)
