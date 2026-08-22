extends CanvasLayer

signal opened
signal closed
signal word_collected(word: String)

var current_instance: Control = null

@onready var dimmer: ColorRect = $Dimmer
@onready var container: Control = $Container


func _unhandled_input(event: InputEvent) -> void:
	if current_instance and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()


func open(scene: PackedScene) -> Control:
	if current_instance:
		close()

	current_instance = scene.instantiate()
	container.add_child(current_instance)
	dimmer.show()
	opened.emit()
	return current_instance


func close() -> void:
	if not current_instance:
		return
	current_instance.queue_free()
	current_instance = null
	dimmer.hide()
	closed.emit()


func _on_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		close()
