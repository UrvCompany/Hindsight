extends Control
class_name DecreeReader

const DECREE_TEXT_1 := "В связи с полученными данными, я - Король королевич, повелеваю выкопать ров перед замком глубиной [u][url=3 м]3 м[/url][/u], заполнить его водой, запустить туда крокодилов."
const DECREE_TEXT_2 := "Второй мой указ - отправить [u][url=всех]всех[/url][/u] воинов патрулировать стену замка!"

@onready var paragraph_1: RichTextLabel = $Paragraph1
@onready var paragraph_2: RichTextLabel = $Paragraph2


func _ready() -> void:
	paragraph_1.text = DECREE_TEXT_1
	paragraph_2.text = DECREE_TEXT_2


func _on_meta_clicked(meta: Variant) -> void:
	SupportingSceneManager.word_collected.emit(str(meta))
