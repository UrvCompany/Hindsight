extends Area2D
const target_scene_path := "res://Scene/Level1/Castle_interior/CI2/Castle_interior_second.tscn"
@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_right.svg")



func _on_mouse_entered() -> void:
	var access_pass = may_i_go() 
	if access_pass:
		CursorManager.show_transition(cursor_texture)


func _on_mouse_exited() -> void:
	CursorManager.reset()


func _on_input_event(
	_viewport: Node, 
	event: InputEvent, 
	_shape_idx: int
	) -> void:
	"""
	При клике определяем путь следующей сцены и переходим на неё.
	"""
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		var scene_path = choise_scene_path()
		if !scene_path:
			return
		get_tree().change_scene_to_file(scene_path)
		


func choise_scene_path():
	"""
	Логика определения след сцены + фиксируем текущую сцену.
	"""
	
	if SceneStateGlobal.STAGE == 0 or SceneStateGlobal.STAGE == 2:
			CursorManager.reset()
			SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path
			return target_scene_path

	if SceneStateGlobal.STAGE == 1:
		return
		
		
func may_i_go():
	"""
	Решаем - есть ли возможность перехода на локацию.
	"""
	if SceneStateGlobal.STAGE == 0 or SceneStateGlobal.STAGE == 2:
		return true
	
	return false
	
