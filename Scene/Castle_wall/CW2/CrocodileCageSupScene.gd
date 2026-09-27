extends Area2D




func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	print('Shaval')
	SupportingSceneManager.word_collected.emit('крокодил')
	get_viewport().set_input_as_handled()
