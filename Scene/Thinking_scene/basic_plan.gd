extends Area2D
class_name Basic_plane


const Basic_plane_chapter_1 := """
План короля по обороне замка следующий:
1) Выкопать [u][url=slot_0]_____[/url][/u] глубиной [u][url=slot_1]________[/url][/u]
2) Заполнить его [u][url=slot_2]______[/url][/u]
3) Запустить в него [u][url=slot_3]______[/url][/u]
4) Отправить [u][url=slot_4]____[/url][/u] армии/ию на патрулирование [u][url=slot_5]_____[/url][/u]
"""


const CORRECT_ANSWERS: Array[String] = [
	"ров",
	"3 м",
	"водой",
	"крокодилов",
	"100",
	"вокруг замка"
]


@onready var Basic_plane_rich_text: RichTextLabel = $Basic_plane_rich_text
@onready var LOH: Sprite2D = $LOH


func _ready() -> void:
	LOH.visible = false
	
	Basic_plane_rich_text.bbcode_enabled = true
	Basic_plane_rich_text.modulate = Color.BLACK
	
	Basic_plane_rich_text.setup_text(Basic_plane_chapter_1)
	Basic_plane_rich_text.set_correct_answers(CORRECT_ANSWERS)
	Basic_plane_rich_text.set_loh(LOH)
