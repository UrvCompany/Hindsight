extends Node2D

const BOOK_SCENE := preload("res://Scene/Notes_scene/Book.tscn")

@export var book_textures: Array[Texture2D] = []
@export var book_scale: float = 0.35

@export var shelf_left_x: float = 150.0
@export var shelf_right_x: float = 1780.0
@export var shelf_y: float = 630.0

@onready var books_container: Node2D = $BooksContainer
@onready var reader: Area2D = $Reader
@onready var reader_sprite: Sprite2D = $Reader/Sprite2D
@onready var reader_collision: CollisionShape2D = $Reader/CollisionShape2D

var is_reader_open := false


func _ready() -> void:
	var shape := RectangleShape2D.new()
	if reader_sprite.texture:
		shape.size = reader_sprite.texture.get_size()
	reader_collision.shape = shape

	_close_reader()
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
		var book := BOOK_SCENE.instantiate()
		book.closed_texture = book_textures[i % book_textures.size()]
		book.scale = Vector2(book_scale, book_scale)
		book.position = Vector2(shelf_left_x + spacing * i, shelf_y)
		book.book_clicked.connect(_open_reader)
		books_container.add_child(book)


func _open_reader() -> void:
	if is_reader_open:
		return
	is_reader_open = true
	reader.show()
	reader.input_pickable = true
	_set_books_pickable(false)


func _close_reader() -> void:
	is_reader_open = false
	reader.hide()
	reader.input_pickable = false
	_set_books_pickable(true)


func _set_books_pickable(value: bool) -> void:
	for book in books_container.get_children():
		book.input_pickable = value


func _on_reader_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_close_reader()
