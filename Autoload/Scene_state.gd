extends Node

enum State {
	EXPLORATION,
	THINKING,
	NOTES
}

var STAGE: int = 1
var CURRENT_LEVEL: int = 0

var current_state := State.EXPLORATION
var current_scene: String

var books_per_level: Array[int] = [4]
var collected_words: Array[String] = []
