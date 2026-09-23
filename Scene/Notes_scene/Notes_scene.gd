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

@export var shelf_left_x: float = 150.0
@export var shelf_right_x: float = 1780.0
@export var shelf_y: float = 630.0


@onready var books_container: Node2D = $BooksContainer
@onready var mode_switch := $ModeSwitch


func _ready() -> void:
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

	# Получаем книги текущего уровня и этапа
	var books: Array = LEVEL_BOOKS.get_books(
		SceneStateGlobal.CURRENT_LEVEL,
		SceneStateGlobal.STAGE
	)

	if books.is_empty():
		return

	# Расстояние между книгами на полке
	var spacing := (
		shelf_right_x - shelf_left_x
	) / float(max(books.size() - 1, 1))


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
		book.page_text_1 = book_data["page_text_1"]
		book.page_text_2 = book_data["page_text_2"]

		# Размер
		book.scale = Vector2(
			book_scale,
			book_scale
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

	spread.set_text(
		book.page_text_1,
		book.page_text_2
	)
