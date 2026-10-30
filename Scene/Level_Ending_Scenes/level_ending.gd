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
		$EndingMenu.overlay.show()
		return
	$EndingMenu.ending_level = ending.level
	$EndingMenu._show_main_options()
	$Content.add_child(content_scene.instantiate())
