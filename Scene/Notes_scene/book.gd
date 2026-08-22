extends Area2D
class_name Book

signal book_clicked(book: Book)

@export var closed_texture: Texture2D
@export_multiline var page_text_1: String = ""
@export_multiline var page_text_2: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	sprite.texture = closed_texture

	var shape := RectangleShape2D.new()
	if closed_texture:
		shape.size = closed_texture.get_size()
	collision_shape.shape = shape


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		book_clicked.emit(self)
