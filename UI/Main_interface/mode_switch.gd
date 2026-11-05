extends Node2D

@export_file("*.tscn") var thinking_scene_path: String
@export_file("*.tscn") var notes_scene_path: String
@onready var navigation: CanvasLayer = $Navigation

func _ready() -> void:
	var modes := [SceneStateGlobal.State.NOTES, SceneStateGlobal.State.EXPLORATION, SceneStateGlobal.State.THINKING]
	for i in range(3):
		var button := $Navigation/Tabs.get_child(i) as Button
		button.disabled = modes[i] == SceneStateGlobal.current_state
		button.pressed.connect(_select.bind(modes[i]))
func set_ui_visible(value: bool) -> void:
	visible = value
	navigation.visible = value

func _select(mode: int) -> void:
	if mode == SceneStateGlobal.current_state: return
	var path: String = SceneStateGlobal.current_scene
	if mode == SceneStateGlobal.State.NOTES: path = notes_scene_path
	elif mode == SceneStateGlobal.State.THINKING: path = thinking_scene_path
	if path.is_empty(): return
	if SceneStateGlobal.current_state == SceneStateGlobal.State.EXPLORATION:
		SceneStateGlobal.current_scene = get_tree().current_scene.scene_file_path
	var previous = SceneStateGlobal.current_state
	SceneStateGlobal.current_state = mode as SceneStateGlobal.State
	if get_tree().change_scene_to_file(path) != OK:
		SceneStateGlobal.current_state = previous
