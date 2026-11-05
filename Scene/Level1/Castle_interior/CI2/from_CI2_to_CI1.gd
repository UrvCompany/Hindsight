extends Area2D

@export_file("*.tscn") var target_scene_path: String = "res://Scene/Level1/Castle_interior/CI1/Castle_interior.tscn"
@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_left.svg")


func _on_mouse_entered() -> void:
	CursorManager.show_transition(cursor_texture)


func _on_mouse_exited() -> void:
	CursorManager.reset()


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if target_scene_path.is_empty():
			return
		
		CursorManager.reset()
		SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path
		get_tree().change_scene_to_file(target_scene_path)
