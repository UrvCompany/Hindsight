extends Control
class_name BookSpread

@onready var paragraph_1: RichTextLabel = $Paragraph1
@onready var paragraph_2: RichTextLabel = $Paragraph2


func set_text(text_1: String, text_2: String) -> void:
	paragraph_1.text = text_1
	paragraph_2.text = text_2


func _on_meta_clicked(meta: Variant) -> void:
	SupportingSceneManager.word_collected.emit(str(meta))
