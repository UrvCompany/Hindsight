extends Button
func _get_drag_data(_at_position: Vector2) -> Variant:
	if text.is_empty(): return null
	var preview := PanelContainer.new()
	preview.add_theme_stylebox_override("panel", preload("res://UI/Main_interface/archive_style.gd").box("eee0bd", "a88c58"))
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color("34291f"))
	label.add_theme_font_size_override("font_size", 24)
	preview.add_child(label)
	set_drag_preview(preview)
	return text
