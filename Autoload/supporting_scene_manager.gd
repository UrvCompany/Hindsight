extends CanvasLayer

signal opened
signal closed
signal word_collected(word: String)

var current_instance: Control = null
var escape_menu: Control = null
var _previous_paused: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if is_instance_valid(current_instance):
		if (
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			var panel := current_instance.get_node_or_null("Panel") as Control
			if panel != null and not panel.get_global_rect().has_point(event.position):
				close()
				get_viewport().set_input_as_handled()
				return
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return
	if is_instance_valid(current_instance):
		close()
	elif is_instance_valid(escape_menu):
		_close_escape_menu()
	else:
		var scene := get_tree().current_scene
		if scene == null or scene.scene_file_path.begins_with("res://UI/"):
			return
		show_escape_menu()
	get_viewport().set_input_as_handled()

func show_escape_menu() -> void:
	if is_instance_valid(escape_menu):
		return
	if is_instance_valid(current_instance):
		close()
	escape_menu = Control.new()
	escape_menu.set_script(load("res://UI/Pause_menu/escape_menu.gd"))
	escape_menu.dismissed.connect(_close_escape_menu)
	container.add_child(escape_menu)
	_previous_paused = get_tree().paused
	get_tree().paused = true
func _close_escape_menu() -> void:
	if is_instance_valid(escape_menu):
		escape_menu.queue_free()
		escape_menu = null
	get_tree().paused = _previous_paused

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
