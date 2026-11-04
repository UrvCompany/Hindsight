extends Node

const CATALOG = preload("res://Data/Endings/ending_catalog.gd")

# Can also be assigned in the inspector for a standalone ending scene.
@export var ending: EndingRequest

func _ready() -> void:
	if ending == null:
		ending = EndingManager.current_ending
	var content_scene: PackedScene = CATALOG.resolve(ending)
	if content_scene == null:
		# Keep the exit menu usable even for an unconfigured ending.
		SupportingSceneManager.show_escape_menu.call_deferred()
		return
	$Content.add_child(content_scene.instantiate())

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE]:
			SupportingSceneManager.show_escape_menu()
			get_viewport().set_input_as_handled()