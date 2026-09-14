extends Button



func _on_pressed() -> void:
	
	if SceneStateGlobal.STAGE == 1 or SceneStateGlobal.STAGE == 2:
		SceneStateGlobal.STAGE += 1
		print('SceneStateGlobal.STAGE=', SceneStateGlobal.STAGE)
		return
	
	if SceneStateGlobal.STAGE == 3:
		SceneStateGlobal.STAGE = 1
		print('SceneStateGlobal.STAGE=', SceneStateGlobal.STAGE)
		return
