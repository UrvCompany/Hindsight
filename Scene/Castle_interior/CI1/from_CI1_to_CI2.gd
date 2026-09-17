extends Area2D

const target_scene_path := preload("res://Scene/Castle_interior/CI2/decree_reader.tscn")

@export var cursor_texture: Texture2D = preload("res://Image/Arrow/cursor_right.png")



func _on_mouse_entered() -> void:
	var access_pass = may_i_go() 
	if access_pass:
		Input.set_custom_mouse_cursor(cursor_texture)


func _on_mouse_exited() -> void:
	Input.set_custom_mouse_cursor(null)


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
	
	if SceneStateGlobal.STAGE == 1 or SceneStateGlobal.STAGE == 3:
			Input.set_custom_mouse_cursor(null)
			SceneStateGlobal.current_scene = get_tree().get_current_scene().scene_file_path
			return target_scene_path

	if SceneStateGlobal.STAGE == 2:
		return
		
		
func may_i_go():
	"""
	Решаем - есть ли возможность перехода на локацию.
	"""
	if SceneStateGlobal.STAGE == 1 or SceneStateGlobal.STAGE == 3:
		return true
	
	return false
	
