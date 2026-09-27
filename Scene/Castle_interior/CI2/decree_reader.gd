extends Control
class_name DecreeReader

const CORRECT_ANSWER := preload("res://Data/CorrectAnswer.gd")

const DECREE_TEXT_1 := "Я, король Альберик III, повелеваю незамедлительно выкопать перед замком [u][url=%s]ров[/url][/u]. Исполнение приказа не терпит промедления." % CORRECT_ANSWER.DITCH

const DECREE_TEXT_2 := "Второй мой указ - отправить [u][url=%s]всех воинов[/url][/u] на патрулирование [u][url=%s]стен замка[/url][/u]. Полагаю, столь простое распоряжение не требует дополнительных разъяснений." % [ CORRECT_ANSWER.WARRIORS, CORRECT_ANSWER.CASTLE_WALL ]

@onready var paragraph_1: RichTextLabel = $Paragraph1
@onready var paragraph_2: RichTextLabel = $Paragraph2


func _ready() -> void:
	paragraph_1.text = DECREE_TEXT_1
	paragraph_2.text = DECREE_TEXT_2


func _on_meta_clicked(meta: Variant) -> void:
	SupportingSceneManager.word_collected.emit(str(meta))
