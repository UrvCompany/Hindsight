extends RichTextEffect

var bbcode := "wordmark"
var target: WeakRef

func _process_custom_fx(char_fx: CharFXTransform) -> bool:
	if char_fx.outline or not char_fx.visible:
		return true
	var label = target.get_ref() if target != null else null
	if label == null:
		return true
	var size := int(char_fx.env.get("size", 28))
	var advance := TextServerManager.get_primary_interface().font_get_glyph_advance(char_fx.font, size, char_fx.glyph_index).x
	label.record_glyph(int(char_fx.env.get("key", -1)), char_fx.range, char_fx.transform.origin + char_fx.offset, advance)
	return true
