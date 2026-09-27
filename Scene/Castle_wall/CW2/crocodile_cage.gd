extends Area2D
class_name CrocodileCage


signal cage_clicked


func _on_input_event(
	_viewport: Node,
	event: InputEvent,
	_shape_idx: int
) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
		):
		cage_clicked.emit()
