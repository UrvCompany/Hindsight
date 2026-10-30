extends RichTextLabel

const WORD_EFFECT = preload("res://UI/CollectibleText/word_underline_effect.gd")
const WORD_OVERLAY = preload("res://UI/CollectibleText/word_underline_overlay.gd")

@export var underline_width: float = 4.0
@export var underline_offset: float = 5.0
@export var available_color := Color("ffcc00")
@export var collected_color := Color("d93432")
@export var pulse_period: float = 1.4

var word_keys: Dictionary = {}
var glyphs: Dictionary = {}
var glyph_frame: int = -1
var hovered_word := ""
var phase: float = 0.0
var overlay: Control

func _ready() -> void:
	bbcode_enabled = true
	threaded = false
	meta_underlined = false
	var effect := WORD_EFFECT.new()
	effect.target = weakref(self)
	install_effect(effect)
	overlay = WORD_OVERLAY.new()
	overlay.target = weakref(self)
	add_child(overlay)
	meta_hover_started.connect(func(meta: Variant): hovered_word = str(meta))
	meta_hover_ended.connect(func(_meta: Variant): hovered_word = "")
	set_collectible_text(text)

func set_collectible_text(source: String) -> void:
	word_keys.clear()
	glyphs.clear()
	glyph_frame = -1
	hovered_word = ""
	var regex := RegEx.new()
	regex.compile("(?s)(?:\\[u\\])?\\[url=([^\\]]+)\\](.*?)\\[/url\\](?:\\[/u\\])?")
	var result := ""
	var cursor := 0
	var font_size := get_theme_font_size("normal_font_size")
	for found in regex.search_all(source):
		result += source.substr(cursor, found.get_start() - cursor)
		var key := word_keys.size()
		word_keys[key] = found.get_string(1)
		result += "[url=%s][wordmark key=%d size=%d]%s[/wordmark][/url]" % [found.get_string(1), key, font_size, found.get_string(2)]
		cursor = found.get_end()
	result += source.substr(cursor)
	text = result

func _process(delta: float) -> void:
	phase = fmod(phase + delta, maxf(pulse_period, 0.1))
	# FX records the actual laid-out glyph positions; the child draws afterwards.
	queue_redraw()
	if overlay != null:
		overlay.queue_redraw()

func record_glyph(key: int, character_range: Vector2i, origin: Vector2, advance: float) -> void:
	var frame := Engine.get_frames_drawn()
	if frame != glyph_frame:
		glyphs.clear()
		glyph_frame = frame
	if key < 0 or not word_keys.has(key):
		return
	var id := "%d:%d:%d:%s" % [key, character_range.x, character_range.y, str(origin)]
	glyphs[id] = {"key": key, "origin": origin, "advance": advance}

func get_underline_segments() -> Array[Dictionary]:
	var rows: Dictionary = {}
	for glyph: Dictionary in glyphs.values():
		var origin: Vector2 = glyph.origin
		var row_id := "%d:%d" % [glyph.key, roundi(origin.y)]
		var left := minf(origin.x, origin.x + glyph.advance)
		var right := maxf(origin.x, origin.x + glyph.advance)
		if not rows.has(row_id):
			rows[row_id] = {"key": glyph.key, "start": Vector2(left, origin.y + underline_offset), "end": Vector2(right, origin.y + underline_offset)}
		else:
			var segment: Dictionary = rows[row_id]
			segment.start.x = minf(segment.start.x, left)
			segment.end.x = maxf(segment.end.x, right)
	var result: Array[Dictionary] = []
	for segment: Dictionary in rows.values():
		result.append(segment)
	return result

func get_word_color(key: int) -> Color:
	var word: String = word_keys.get(key, "")
	var color := collected_color if SceneStateGlobal.collected_words.has(word) else available_color
	var wave := 0.5 + 0.5 * sin(TAU * phase / maxf(pulse_period, 0.1))
	color.a = lerpf(0.6, 1.0, wave)
	if word == hovered_word:
		color.a = 1.0
	return color
