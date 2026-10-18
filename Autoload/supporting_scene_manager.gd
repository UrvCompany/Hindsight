extends CanvasLayer

signal opened
signal closed
signal word_collected(word: String)

var current_instance: Control = null

@onready var dimmer: ColorRect = $Dimmer
@onready var container: Control = $Container


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(current_instance):
		return

	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		return

	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		var content_rect: Rect2 = current_instance.get_global_rect()
		if current_instance is DialogueBox:
			var panel: Control = current_instance.get_node_or_null("Panel")
			if panel != null:
				content_rect = panel.get_global_rect()

		if not content_rect.has_point(event.position):
			close()
			get_viewport().set_input_as_handled()


func open(scene: PackedScene, data: Variant = null) -> Control:
	if is_instance_valid(current_instance):
		close()

	var instance: Node = scene.instantiate()

	if not instance is Control:
		push_error("Вспомогательная сцена должна иметь корень Control")
		instance.free()
		return null

	current_instance = instance as Control
	container.add_child(current_instance)

	if data != null:
		if current_instance.has_method("setup"):
			current_instance.setup(data)
		else:
			push_warning("У сцены отсутствует метод setup()")

	dimmer.show()

	if is_instance_valid(current_instance):
		current_instance.show()
	else:
		push_error("Вспомогательная сцена была закрыта во время настройки")
		return null

	opened.emit()
	return current_instance


func close() -> void:
	if not is_instance_valid(current_instance):
		return

	current_instance.queue_free()
	current_instance = null

	dimmer.hide()
	closed.emit()
