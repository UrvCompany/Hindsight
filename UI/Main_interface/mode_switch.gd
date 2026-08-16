extends Node2D

@export_file("*.tscn") var thinking_scene_path: String


func _on_button_pressed() -> void:
	SceneStateGlobal.current_state = (SceneStateGlobal.current_state + 1) % 3
	$Pivo.rotation_degrees += 120
	print(SceneStateGlobal.current_state)
	match SceneStateGlobal.current_state:
		SceneStateGlobal.State.THINKING:
			if thinking_scene_path.is_empty():
				return
			get_tree().change_scene_to_file(thinking_scene_path)

		SceneStateGlobal.State.EXPLORATION:
			pass

		SceneStateGlobal.State.NOTES:
			pass
