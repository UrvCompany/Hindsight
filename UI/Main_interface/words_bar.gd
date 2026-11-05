extends CanvasLayer
const CARD = preload("res://UI/Main_interface/WordCard.tscn")
@onready var grid: GridContainer = $Panel/Scroll/Grid

func _ready() -> void:
	SupportingSceneManager.word_collected.connect(add_word)
	set_words(SceneStateGlobal.collected_words)

func add_word(word: String) -> void:
	if word.is_empty() or SceneStateGlobal.collected_words.has(word): return
	SceneStateGlobal.collected_words.append(word)
	set_words(SceneStateGlobal.collected_words)

func set_words(words: Array[String]) -> void:
	for child in grid.get_children():
		grid.remove_child(child)
		child.queue_free()
	for word in words:
		var button := CARD.instantiate() as Button
		button.text = word
		button.tooltip_text = word
		grid.add_child(button)
