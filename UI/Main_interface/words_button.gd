extends Button

func _get_drag_data(_at_position: Vector2) -> Variant:
	

	var word := text
	

	if word.is_empty():
		return null

	var preview := Label.new()
	preview.text = word
	preview.add_theme_color_override("font_color", Color.BLACK)

	set_drag_preview(preview)

	return word
