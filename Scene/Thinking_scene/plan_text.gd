extends RichTextLabel
signal edited
var template := ""
var words: Dictionary = {}
var hovered := ""
var read_only := false

func _ready() -> void:
	bbcode_enabled = true
	meta_hover_started.connect(func(meta): hovered = str(meta))
	meta_hover_ended.connect(func(_meta): hovered = "")
	meta_clicked.connect(func(meta):
		if not read_only:
			words.erase(str(meta))
			refresh()
			edited.emit())

func refresh() -> void:
	var regex := RegEx.new()
	regex.compile("\\[url=(slot_\\d+)\\](.*?)\\[/url\\]")
	var result := ""
	var cursor := 0
	for found in regex.search_all(template):
		result += template.substr(cursor, found.get_start() - cursor)
		var key := found.get_string(1)
		var value := str(words.get(key, "________"))
		result += "[color=#805022][url=%s]%s[/url][/color]" % [key, value.replace("[", "[lb]")]
		cursor = found.get_end()
	text = result + template.substr(cursor)

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	return not read_only and data is String and data in SceneStateGlobal.collected_words and hovered.begins_with("slot_")

func _drop_data(_position: Vector2, data: Variant) -> void:
	if not _can_drop_data(_position, data): return
	words[hovered] = data
	refresh()
	edited.emit()
