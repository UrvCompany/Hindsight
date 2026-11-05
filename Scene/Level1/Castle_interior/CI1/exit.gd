extends Area2D

@export_file("*.tscn") var general_scene_path: String
@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_up.svg")


func _on_mouse_entered() -> void:
	CursorManager.show_transition(cursor_texture)


func _on_mouse_exited() -> void:
	CursorManager.reset()
	

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact()


func interact() -> void:
	if general_scene_path.is_empty():
		return
		
	CursorManager.reset()
	get_tree().change_scene_to_file(general_scene_path)
	
