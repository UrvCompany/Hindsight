extends RefCounted

static func box(color: String, border: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(color)
	style.border_color = Color(border)
	style.set_border_width_all(1)
	style.set_corner_radius_all(3)
	style.content_margin_left = 18
	style.content_margin_right = 18
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	return style

static func button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", box("dfd0ae", "a88c58"))
	button.add_theme_stylebox_override("hover", box("f2e2bd", "e1bc70"))
	button.add_theme_stylebox_override("pressed", box("bea77d", "e1bc70"))
	button.add_theme_stylebox_override("disabled", box("6b5132", "d8b878"))
	for state in ["font_color", "font_hover_color", "font_pressed_color"]:
		button.add_theme_color_override(state, Color("34291f"))
	button.add_theme_color_override("font_disabled_color", Color("fff0cb"))
	button.add_theme_font_size_override("font_size", 23)
