extends Control
class_name DecreeReader

const CORRECT_ANSWER := preload("res://Data/CorrectAnswer.gd")

const DECREE_TEXT_1 := "Дополнение после обследования грунта. Вместо предварительного сухого укрепления устроить перед замком [u][url=%s]ров[/url][/u] с водой из реки. Прежний проект считать отменённым." % CORRECT_ANSWER.DITCH

const DECREE_TEXT_2 := "После наполнения рва выпустить доставленных хищников. Отправить [u][url=%s]всех воинов[/url][/u] на патрулирование [u][url=%s]стен замка[/url][/u]. Прежнее расписание внутренних постов отменить." % [CORRECT_ANSWER.WARRIORS, CORRECT_ANSWER.CASTLE_WALL]

@onready var paragraph_1: RichTextLabel = $Paragraph1
@onready var paragraph_2: RichTextLabel = $Paragraph2


func _ready() -> void:
	paragraph_1.set_collectible_text(DECREE_TEXT_1)
	paragraph_2.set_collectible_text(DECREE_TEXT_2)


func _on_meta_clicked(meta: Variant) -> void:
	SupportingSceneManager.word_collected.emit(str(meta))
