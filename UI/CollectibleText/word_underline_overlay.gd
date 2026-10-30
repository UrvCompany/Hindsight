extends Control

var target: WeakRef

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _draw() -> void:
	var label = target.get_ref() if target != null else null
	if label == null:
		return
	for segment: Dictionary in label.get_underline_segments():
		var color: Color = label.get_word_color(segment.key)
		draw_line(segment.start, segment.end, color, label.underline_width, true)
