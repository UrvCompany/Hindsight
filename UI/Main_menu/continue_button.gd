extends Button

const NORMAL_FONT = preload("res://UI/Fonts/Montserrat_FontVariation_wght_400.tres")
const BOLD_FONT = preload("res://UI/Fonts/Montserrat_FontVariation_wght_600.tres")

func _ready() -> void:
	add_theme_font_override("font", NORMAL_FONT)
	pressed.connect(_on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	disabled = not SaveManager.has_save()

func _on_mouse_entered() -> void:
	add_theme_font_override("font", BOLD_FONT)

func _on_mouse_exited() -> void:
	add_theme_font_override("font", NORMAL_FONT)

func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://UI/Chapter_select/ChapterSelect.tscn")
