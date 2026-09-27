extends Button


func _on_pressed() -> void:
	
	if SceneStateGlobal.STAGE == 2:
		print('sukablyat')
		SceneStateGlobal.STAGE = 0
	
	if SceneStateGlobal.STAGE == 0 or SceneStateGlobal.STAGE == 1:
		SceneStateGlobal.STAGE += 1
	
	

	SceneStateGlobal.collected_words = []
	SceneStateGlobal.current_scene = SceneStateGlobal.HOME_SCENE[SceneStateGlobal.CURRENT_LEVEL]
	get_tree().change_scene_to_file(SceneStateGlobal.HOME_SCENE[SceneStateGlobal.CURRENT_LEVEL])
	
	
	return
