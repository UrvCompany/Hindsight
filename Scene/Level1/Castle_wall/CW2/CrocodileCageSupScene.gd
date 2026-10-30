extends Area2D


const CORRECT_ANSWER := preload("res://Data/CorrectAnswer.gd")

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		):
		SupportingSceneManager.word_collected.emit(CORRECT_ANSWER.CROCODILE)
	
