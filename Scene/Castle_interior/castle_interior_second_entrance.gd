extends Area2D

@export_file("*.tscn") var target_scene_path: String = "res://Scene/Castle_interior/Castle_interior_second.tscn"
@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_right.png")


func _on_mouse_entered() -> void:
	Input.set_custom_mouse_cursor(cursor_texture)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(null)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if target_scene_path.is_empty():
			return

		Input.set_custom_mouse_cursor(null)
		SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path
		get_tree().change_scene_to_file(target_scene_path)
