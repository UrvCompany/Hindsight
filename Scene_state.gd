extends Node

enum State {
	EXPLORATION,
	THINKING,
	NOTES
}

var current_state := State.EXPLORATION
var current_degre: int = 0
var current_scene: String
var current_level: int = 0
var books_per_level: Array[int] = [4]
