extends Area2D

@onready var outline = $"../Outline"

# Сцена интерьера замка
@export_file("*.tscn") var catle_interior_scene_path: String

func _on_mouse_entered() -> void:
	outline.show()


func _on_mouse_exited() -> void:
	outline.hide()


func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			interact()


func interact() -> void:
	print("general clicked!")
	if catle_interior_scene_path.is_empty():
		print("pidor")
		return
	get_tree().change_scene_to_file(catle_interior_scene_path)
	
