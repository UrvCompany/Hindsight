extends Node2D

@export_file("*.tscn") var thinking_scene_path: String

enum State {
	EXPLORATION,
	THINKING,
	NOTES
}

var current_state := State.EXPLORATION


func _on_button_pressed() -> void:
	current_state = (current_state + 1) % 3
	$Pivo.rotation_degrees += 120
	print(current_state)
	match current_state:
		State.THINKING:
			if thinking_scene_path.is_empty():
				return
			get_tree().change_scene_to_file(thinking_scene_path)

		State.EXPLORATION:
			# логика Exploration
			pass

		State.NOTES:
			# логика Notes
			pass
