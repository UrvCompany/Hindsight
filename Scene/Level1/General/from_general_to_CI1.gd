extends Area2D


# Сцена интерьера замка
@export_file("*.tscn") var castle_interior_scene_path: String
@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_up.svg")


func _on_mouse_entered() -> void:
	CursorManager.show_transition(cursor_texture)


func _on_mouse_exited() -> void:
	CursorManager.reset()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			CursorManager.reset()
			interact()


func interact() -> void:
	
	if castle_interior_scene_path.is_empty():
		return
														
	get_tree().change_scene_to_file(castle_interior_scene_path)
	
