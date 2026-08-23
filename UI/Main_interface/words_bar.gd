extends CanvasLayer

const WORDS_GROUP := "Words_slots"

var slots: Array[Node2D] = []


func _ready() -> void:
	SupportingSceneManager.word_collected.connect(add_word)

	for n in get_tree().get_nodes_in_group(WORDS_GROUP):
		slots.append(n as Node2D)

	slots.sort_custom(func(a: Node2D, b: Node2D) -> bool:
		if not is_equal_approx(a.position.y, b.position.y):
			return a.position.y < b.position.y
		return a.position.x < b.position.x
	)

	set_words(SceneStateGlobal.collected_words)


func add_word(word: String) -> void:
	if word.is_empty() or SceneStateGlobal.collected_words.has(word):
		return
	SceneStateGlobal.collected_words.append(word)
	set_words(SceneStateGlobal.collected_words)


func set_words(words: Array[String]) -> void:
	for i in slots.size():
		var slot := slots[i]
		var button := slot.get_node("Button") as Button
		
		if i < words.size():
			button.text = words[i]
			slot.visible = true
		else:
			button.text = ""
			slot.visible = false
