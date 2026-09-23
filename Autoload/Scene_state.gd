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
var STAGE: int = 1


# Текущий уровень.
var CURRENT_LEVEL: int = 0


# Текущее состояние игры.
var current_state: State = State.EXPLORATION


# Текущая игровая сцена.
var current_scene: String = ""


# Слова, которые игрок уже собрал.
var collected_words: Array[String] = []
