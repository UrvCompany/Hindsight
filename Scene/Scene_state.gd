extends Node

enum State {
	EXPLORATION,
	THINKING,
	NOTES
}

var current_state := State.EXPLORATION
