extends Button

const CORRECT_ANSWER := preload("res://Data/CorrectAnswer.gd")



func _on_pressed() -> void:
	
	print('SceneStateGlobal.STAGE: ', SceneStateGlobal.STAGE)
	print('SceneStateGlobal.CURRENT_LEVEL: ', SceneStateGlobal.CURRENT_LEVEL)
	print('get_current_scene: ', get_tree().get_current_scene().scene_file_path)
	
	if (
		SceneStateGlobal.STAGE == 1 
		and SceneStateGlobal.CURRENT_LEVEL == 0
		and get_tree().get_current_scene().scene_file_path == "res://Scene/Castle_wall/CW2/castle_wall2.tscn"
		):
			
		
			SupportingSceneManager.word_collected.emit(CORRECT_ANSWER.THRONE_ROOM)
			
	elif (
		SceneStateGlobal.STAGE == 1 
		and SceneStateGlobal.CURRENT_LEVEL == 0
		and get_tree().get_current_scene().scene_file_path == "res://Scene/Village/Tavern.tscn"
		):
		
		SupportingSceneManager.word_collected.emit(CORRECT_ANSWER.NIGHT) 
		SupportingSceneManager.word_collected.emit(CORRECT_ANSWER.TUNNEL)
		
		
	elif (
		SceneStateGlobal.STAGE == 1 
		and SceneStateGlobal.CURRENT_LEVEL == 0
		and get_tree().get_current_scene().scene_file_path == "res://Scene/Village/Basement.tscn"
		):
		print('Палево')
		SupportingSceneManager.word_collected.emit(CORRECT_ANSWER.DEPTH)
