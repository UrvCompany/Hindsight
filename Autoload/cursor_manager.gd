extends Node

const DEFAULT = preload("res://Image/Arrow/cursor_default.svg")

func _ready() -> void:
	Input.set_custom_mouse_cursor(DEFAULT, Input.CURSOR_POINTING_HAND, Vector2(5, 3))
	reset()

func reset() -> void:
	Input.set_custom_mouse_cursor(DEFAULT, Input.CURSOR_ARROW, Vector2(5, 3))

func show_transition(texture: Texture2D) -> void:
	var hotspot := Vector2(24, 24)
	if texture != null:
		var name := texture.resource_path.get_file()
		if "up" in name: hotspot = Vector2(24, 3)
		elif "down" in name: hotspot = Vector2(24, 45)
		elif "left" in name: hotspot = Vector2(3, 24)
		elif "right" in name: hotspot = Vector2(45, 24)
	Input.set_custom_mouse_cursor(texture, Input.CURSOR_ARROW, hotspot)
