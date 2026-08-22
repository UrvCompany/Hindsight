extends Node2D
@export_file("*.tscn") var thinking_scene_path: String
@export_file("*.tscn") var notes_scene_path: String


func _ready():
	$Pivo.rotation_degrees = SceneStateGlobal.current_degre


func set_ui_visible(value: bool) -> void:
	visible = value
	$Area2D/Words_bar_background/CanvasLayer.visible = value


func _on_button_pressed() -> void:

	var previous_state := SceneStateGlobal.current_state

	SceneStateGlobal.current_state = (SceneStateGlobal.current_state + 1) % 3
	SceneStateGlobal.current_degre = (SceneStateGlobal.current_degre + 120) % 360

	if previous_state == SceneStateGlobal.State.EXPLORATION:
		SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path

	$Pivo.rotation_degrees = SceneStateGlobal.current_degre

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
