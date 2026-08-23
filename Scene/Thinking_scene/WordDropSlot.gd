extends Button

var word := ""

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is String and not data.is_empty()
	
func _drop_data(_at_position: Vector2, data: Variant) -> void:
	word = data
	text = word
