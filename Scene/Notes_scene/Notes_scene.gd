extends Node2D


const BOOK_SCENE := preload(
	"res://Scene/Notes_scene/Book.tscn"
	)

const BOOK_SPREAD_SCENE := preload(
	"res://Scene/Notes_scene/book_spread.tscn"
	)

const LEVEL_BOOKS := preload(
	"res://Data/LevelBooks.gd"
	)


@export var book_textures: Array[Texture2D] = []
@export var book_scale: float = 0.35

@export var shelf_left_x: float = 390.0
@export var shelf_right_x: float = 1530.0
@export var shelf_y_1: float = 665.0
@export var shelf_y_2: float = 330.0


@onready var books_container: Node2D = $BooksContainer
@onready var mode_switch := $ModeSwitch


func _ready() -> void:
	book_textures.clear()
	var atlas_image = load("res://Image/Notes_screen/book_spines_painterly.png")
	var regions = [Rect2(56, 52, 142, 906), Rect2(241, 67, 140, 890), Rect2(424, 67, 139, 890), Rect2(601, 81, 145, 877), Rect2(789, 69, 145, 889), Rect2(980, 78, 142, 880), Rect2(1165, 83, 136, 873), Rect2(1349, 81, 133, 877)]
	for region in regions:
		var atlas := AtlasTexture.new()
		atlas.atlas = atlas_image
		atlas.region = region
		book_textures.append(atlas)
	SupportingSceneManager.opened.connect(
		func():
			mode_switch.set_ui_visible(false)
			)

	SupportingSceneManager.closed.connect(
		func():
			mode_switch.set_ui_visible(true)
			)

	generate_books()


func generate_books() -> void:
	# Очищаем старые книги
	for child in books_container.get_children():
		child.queue_free()

	var level := SceneStateGlobal.CURRENT_LEVEL
	match SceneStateGlobal.STAGE:
		0:
			generate_shelf(LEVEL_BOOKS.get_books(level, 0), shelf_y_1)
		1:
			generate_shelf(LEVEL_BOOKS.get_books(level, 1), shelf_y_2)
		2:
			generate_shelf(LEVEL_BOOKS.get_books(level, 0), shelf_y_1)
			generate_shelf(LEVEL_BOOKS.get_books(level, 1), shelf_y_2)


func generate_shelf(books: Array, shelf_y: float) -> void:
	if books.is_empty():
		return

	# Расстояние между книгами на полке
	var spacing := (shelf_right_x - shelf_left_x) / float(max(books.size() - 1, 1))

	# Создаём книги
	for position_index in books.size():

		var book_data: Dictionary = books[position_index]

		var book_index: int = book_data["book_index"]


		# Проверяем наличие текстуры
		if book_index < 0 or book_index >= book_textures.size():
			continue


		var book := BOOK_SCENE.instantiate() as Book

		# Данные книги
		book.closed_texture = book_textures[book_index]
		book.cover_index = book_index
		book.page_text_1 = book_data["page_text_1"]
		book.page_text_2 = book_data["page_text_2"]

		# Размер
		book.scale = Vector2(
			90.0 / book.closed_texture.get_width() * book_scale / 0.35,
			320.0 / book.closed_texture.get_height() * book_scale / 0.35
			)
			
		# Позиция на полке
		book.position = Vector2(
			shelf_left_x + spacing * position_index,
			shelf_y
			)

		# Обработка нажатия
		book.book_clicked.connect(
			_on_book_clicked
			)

		books_container.add_child(book)


func _on_book_clicked(book: Book) -> void:
	var spread := SupportingSceneManager.open(
		BOOK_SPREAD_SCENE
	) as BookSpread

	spread.set_cover(book.cover_index)
	spread.set_text(
		book.page_text_1,
		book.page_text_2
	)
