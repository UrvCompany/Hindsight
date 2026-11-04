extends Control

const CHAPTERS := "res://UI/Chapter_select/ChapterSelect.tscn"
const PAGES := [
	preload("res://Image/Intro/intro_page_01.png"),
	preload("res://Image/Intro/intro_page_02.png"),
	preload("res://Image/Intro/intro_page_03.png")
]
const CAPTIONS := [
	"Ночью музей был закрыт. Для четверых друзей это оказалось лишь поводом заглянуть внутрь.",
	"За служебной дверью — ни голосов, ни шагов. Только свет фонаря и чужая история.",
	"Здесь восстанавливали картины великих революций: тех, что победили, и тех, что были подавлены.",
	"Для одних восстание стало началом свободы. Для других — последней надеждой.",
	"За выставочными залами тянулись бесконечные полки. Тысячи трудов о тех, кто менял историю.",
	"Историки спорили даже на страницах книг. Одни видели героев там, где другие — мятежников.",
	"Но одна книга словно ждала именно их. Между страницами проступил тёплый свет.",
	"Небо расколола молния. Страницы поднялись в воздух — и больше не опустились.",
	"Свет вырвался из книги. Пространство над ней дрогнуло и начало раскрываться.",
	"Друзья схватились за руки. Воронка уже тянула к себе всё вокруг.",
	"Пол исчез из-под ног. Крики затерялись в шелесте тысяч страниц.",
	"По ту сторону ждала история. Теперь им предстояло стать её частью."
]

var stage: Control
var panels: Array[Control] = []
var page := 0
var revealed := 0
var fade: Tween
var counter: Label
var next_button: Button
var leaving := false

func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("0b0d11")
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	stage = Control.new()
	stage.size = Vector2(1920, 1200)
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	for i in range(4):
		var panel := Control.new()
		panel.position = Vector2((i % 2) * 960, (i / 2) * 540)
		panel.size = Vector2(960, 540)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage.add_child(panel)
		panels.append(panel)
		var art := TextureRect.new()
		art.name = "Art"
		art.size = panel.size
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(art)
		var box := Panel.new()
		box.position = Vector2(24, 414)
		box.size = Vector2(912, 104)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.035, 0.045, 0.06, 0.91)
		style.border_color = Color("9e8359")
		style.border_width_left = 3
		box.add_theme_stylebox_override("panel", style)
		panel.add_child(box)
		var caption := Label.new()
		caption.name = "Caption"
		caption.position = Vector2(44, 424)
		caption.size = Vector2(872, 84)
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.add_theme_font_size_override("font_size", 26)
		caption.add_theme_color_override("font_color", Color("eee5d5"))
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		panel.add_child(caption)
	counter = Label.new()
	counter.position = Vector2(30, 1124)
	counter.add_theme_font_size_override("font_size", 24)
	counter.add_theme_color_override("font_color", Color("bfa47b"))
	stage.add_child(counter)
	var skip := Button.new()
	skip.text = "Пропустить интро"
	skip.position = Vector2(1170, 1110)
	skip.size = Vector2(320, 64)
	skip.add_theme_font_size_override("font_size", 24)
	skip.pressed.connect(_finish)
	stage.add_child(skip)
	next_button = Button.new()
	next_button.position = Vector2(1520, 1110)
	next_button.size = Vector2(370, 64)
	next_button.add_theme_font_size_override("font_size", 24)
	next_button.pressed.connect(_advance)
	stage.add_child(next_button)
	resized.connect(_layout)
	_layout()
	_show_page()

func _layout() -> void:
	var factor := minf(size.x / 1920.0, size.y / 1200.0)
	stage.scale = Vector2.ONE * factor
	stage.position = (size - Vector2(1920, 1200) * factor) / 2.0

func _show_page() -> void:
	revealed = 0
	var texture: Texture2D = PAGES[page]
	var half := texture.get_size() / 2.0
	for i in range(4):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(Vector2((i % 2) * half.x, (i / 2) * half.y), half)
		(panels[i].get_node("Art") as TextureRect).texture = atlas
		(panels[i].get_node("Caption") as Label).text = CAPTIONS[page * 4 + i]
		panels[i].modulate.a = 0.0
	_reveal()

func _reveal() -> void:
	if fade and fade.is_running():
		fade.kill()
		panels[revealed - 1].modulate.a = 1.0
	fade = create_tween()
	fade.tween_property(panels[revealed], "modulate:a", 1.0, 0.65)
	revealed += 1
	counter.text = "Пролог  •  %d / 3     ·     Кадр %d / 12" % [page + 1, page * 4 + revealed]
	next_button.text = "Далее  →" if revealed < 4 or page < 2 else "К выбору главы  →"

func _advance() -> void:
	if leaving:
		return
	if revealed < 4:
		_reveal()
	elif page < 2:
		if fade:
			fade.kill()
		page += 1
		_show_page()
	else:
		_finish()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed):
		get_viewport().set_input_as_handled()
		_advance()

func _finish() -> void:
	if leaving:
		return
	leaving = true
	get_tree().change_scene_to_file(CHAPTERS)
