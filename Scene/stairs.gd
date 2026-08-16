extends Area2D

@onready var exit_outline = $Stairs_outline
@export_file("*.tscn") var general_scene_path: String



func _on_mouse_entered() -> void:
	if general_scene_path.is_empty():
		return
	exit_outline.show()


func _on_mouse_exited() -> void:
	if general_scene_path.is_empty():
		return
	exit_outline.hide()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact()


func interact() -> void:
	if general_scene_path.is_empty():
		return
	get_tree().change_scene_to_file(general_scene_path)
	
