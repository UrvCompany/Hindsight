extends Node2D

const BOOK_SCENE := preload("res://Scene/Notes_scene/Book.tscn")
const BOOK_SPREAD_SCENE := preload("res://Scene/Notes_scene/book_spread.tscn")

const BOOK_TEXTS_1: Array[String] = [
	"Замок короля превосходил все самые дерзкие представления того времени. Высота стен достигала [u][url=6 м]6 м[/url][/u].",
]
const BOOK_TEXTS_2: Array[String] = [
	"Сточные воды из замка направлялись прямиком в [u][url=ров]ров[/url][/u] перед его стенами, который имел глубину [u][url=10 м]10 м[/url][/u].",
]

@export var book_textures: Array[Texture2D] = []
@export var book_scale: float = 0.35

@export var shelf_left_x: float = 150.0
@export var shelf_right_x: float = 1780.0
@export var shelf_y: float = 630.0

@onready var books_container: Node2D = $BooksContainer
@onready var mode_switch := $ModeSwitch


func _ready() -> void:
	SupportingSceneManager.opened.connect(func(): mode_switch.set_ui_visible(false))
	SupportingSceneManager.closed.connect(func(): mode_switch.set_ui_visible(true))

	generate_books()


func generate_books() -> void:
	for child in books_container.get_children():
		child.queue_free()

	if book_textures.is_empty():
		return

	var level := clampi(SceneStateGlobal.current_level, 0, SceneStateGlobal.books_per_level.size() - 1)
	var count := SceneStateGlobal.books_per_level[level]
	var spacing := (shelf_right_x - shelf_left_x) / float(max(count - 1, 1))

	for i in count:
		var texture_index := i % book_textures.size()
		var book := BOOK_SCENE.instantiate() as Book
		book.closed_texture = book_textures[texture_index]
		book.page_text_1 = BOOK_TEXTS_1[texture_index] if texture_index < BOOK_TEXTS_1.size() else ""
		book.page_text_2 = BOOK_TEXTS_2[texture_index] if texture_index < BOOK_TEXTS_2.size() else ""
		book.scale = Vector2(book_scale, book_scale)
		book.position = Vector2(shelf_left_x + spacing * i, shelf_y)
		book.book_clicked.connect(_on_book_clicked)
		books_container.add_child(book)


func _on_book_clicked(book: Book) -> void:
	var spread := SupportingSceneManager.open(BOOK_SPREAD_SCENE) as BookSpread
	spread.set_text(book.page_text_1, book.page_text_2)
