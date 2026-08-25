extends Area2D


@onready var wall_stairs_outline = $WallStairsOutline

@export_file("*.tscn") var castle_interior_scene_path: String
@export var cursor_texture: Texture2D


func _on_mouse_entered() -> void:
	if castle_interior_scene_path.is_empty():
		return

	wall_stairs_outline.show()

	if cursor_texture:
		Input.set_custom_mouse_cursor(cursor_texture)


func _on_mouse_exited() -> void:
	if castle_interior_scene_path.is_empty():
		return

	wall_stairs_outline.hide()
	Input.set_custom_mouse_cursor(null)


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact()


func interact() -> void:

	if castle_interior_scene_path.is_empty():
		return

	Input.set_custom_mouse_cursor(null)
	get_tree().change_scene_to_file(castle_interior_scene_path)
