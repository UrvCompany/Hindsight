extends Node2D


@export_file("*.tscn") var thinking_scene_path: String
@export_file("*.tscn") var notes_scene_path: String


func _ready() -> void:
	#$Pivo.rotation_degrees = SceneStateGlobal.current_degre

	match SceneStateGlobal.current_state:
		SceneStateGlobal.State.EXPLORATION:
			update_mode_outline(
				$Area2D/Words_bar_background/CanvasLayer/Exploration
			)

		SceneStateGlobal.State.THINKING:
			update_mode_outline(
				$Area2D/Words_bar_background/CanvasLayer/Thinking
			)

		SceneStateGlobal.State.NOTES:
			update_mode_outline(
				$Area2D/Words_bar_background/CanvasLayer/Notes
			)


func set_ui_visible(value: bool) -> void:
	visible = value
	$Area2D/Words_bar_background/CanvasLayer.visible = value


func _on_button_pressed() -> void:

	var previous_state = SceneStateGlobal.current_state

	SceneStateGlobal.current_state = (SceneStateGlobal.current_state + 1) % 3
	SceneStateGlobal.current_degre = (SceneStateGlobal.current_degre + 120) % 360

	if previous_state == SceneStateGlobal.State.EXPLORATION:
		SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path

	#$Pivo.rotation_degrees = SceneStateGlobal.current_degre

	match SceneStateGlobal.current_state:
		SceneStateGlobal.State.THINKING:
			if thinking_scene_path.is_empty():
				return

			get_tree().change_scene_to_file(thinking_scene_path)

		SceneStateGlobal.State.EXPLORATION:
			get_tree().change_scene_to_file(SceneStateGlobal.current_scene)

		SceneStateGlobal.State.NOTES:
			if notes_scene_path.is_empty():
				return

			get_tree().change_scene_to_file(notes_scene_path)


func update_mode_outline(active_label: Label) -> void:
	var labels := [
		$Area2D/Words_bar_background/CanvasLayer/Exploration,
		$Area2D/Words_bar_background/CanvasLayer/Thinking,
		$Area2D/Words_bar_background/CanvasLayer/Notes
	]

	for label in labels:
		label.remove_theme_color_override("font_outline_color")
		label.remove_theme_constant_override("outline_size")

	active_label.add_theme_color_override(
		"font_outline_color",
		Color.CADET_BLUE
	)

	active_label.add_theme_constant_override(
		"outline_size",
		10
	)
