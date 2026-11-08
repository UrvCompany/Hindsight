
extends Control
class_name BookSpread

@onready var paragraph_1: RichTextLabel = $Paragraph1
@onready var paragraph_2: RichTextLabel = $Paragraph2

const COLORS := [
	Color("722c32"),
	Color("304b39"),
	Color("263e5a"),
	Color("68432b"),
	Color("303133"),
	Color("97702e"),
	Color("365f61"),
	Color("59405c")
]

const REGULAR_FONT = preload("res://UI/Fonts/Montserrat_FontVariation_wght_400.tres")
const BOLD_FONT = preload("res://UI/Fonts/Montserrat_FontVariation_wght_600.tres")


func _ready() -> void:
	$Background.material = $Background.material.duplicate()

	for paragraph in [paragraph_1, paragraph_2]:
		paragraph.add_theme_font_override("normal_font", REGULAR_FONT)
		paragraph.add_theme_font_override("bold_font", BOLD_FONT)
		paragraph.add_theme_font_size_override("bold_font_size", 26)
		paragraph.add_theme_font_size_override("normal_font_size", 30)
		paragraph.add_theme_constant_override("line_separation", 9)
		paragraph.add_theme_color_override("default_color", Color("382c22"))
		paragraph.underline_width = 2.0
		paragraph.available_color = Color("a8791d")
		paragraph.collected_color = Color("943c32")

	for i in range(2):
		var heading := Label.new()
		heading.text = "ИСТОРИЧЕСКИЕ ЗАПИСКИ" if i == 0 else "СВИДЕТЕЛЬСТВА ЭПОХИ"
		heading.position = Vector2(150 + i * 680, 100)
		heading.size = Vector2(510, 40)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heading.add_theme_font_override("font", REGULAR_FONT)
		heading.add_theme_font_size_override("font_size", 20)
		heading.add_theme_color_override("font_color", Color("806c50"))
		heading.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(heading)

		var number := Label.new()
		number.text = str(i + 1)
		number.position = Vector2(150 + i * 680, 800)
		number.size = Vector2(510, 40)
		number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		number.add_theme_font_override("font", REGULAR_FONT)
		number.add_theme_color_override("font_color", Color("806c50"))
		number.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(number)

	get_viewport().size_changed.connect(_layout)
	_layout()


func _layout() -> void:
	var viewport := get_viewport_rect().size
	# Reserve the bottom word tray, which stays available while reading.
	var reading_area := Vector2(viewport.x, viewport.y * 0.77)
	var factor := minf(reading_area.x / 1680.0, reading_area.y / 1080.0)
	scale = Vector2.ONE * factor
	position = (reading_area - size * factor) / 2.0


func set_cover(index: int) -> void:
	$Background.material.set_shader_parameter("cover_color", COLORS[posmod(index, COLORS.size())])


func set_text(text_1: String, text_2: String) -> void:
	paragraph_1.set_collectible_text("[indent]" + text_1 + "[/indent]")
	paragraph_2.set_collectible_text("[indent]" + text_2 + "[/indent]")


func _on_meta_clicked(meta: Variant) -> void:
	SupportingSceneManager.word_collected.emit(str(meta))
