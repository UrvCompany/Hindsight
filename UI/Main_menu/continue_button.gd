extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)
	disabled = not SaveManager.has_save()

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Chapter_select/ChapterSelect.tscn")
