
extends CharacterBody2D
class_name King

signal character_clicked(character_data: CharacterData)

@export var character_data: CharacterData


func _on_area_2d_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		):
		print('Клик на короля')
		if character_data != null:
			character_clicked.emit(character_data)
		else:
			push_warning("King: character_data не задан")
