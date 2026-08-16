extends Area2D

@onready var stairs_outline = $Stairs_outline

func _on_mouse_entered() -> void:
	stairs_outline.show()


func _on_mouse_exited() -> void:
	stairs_outline.hide()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact()


func interact() -> void:
	print("stairs clicked!")
