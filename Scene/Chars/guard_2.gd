extends CharacterBody2D
class_name Guard

signal guard_clicked

func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if (
				SceneStateGlobal.CURRENT_LEVEL == 0 
				and SceneStateGlobal.STAGE == 1):
				
					guard_clicked.emit()
				
