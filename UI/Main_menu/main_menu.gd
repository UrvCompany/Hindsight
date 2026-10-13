extends Node


@onready var _start_button: Button = $LeftPanel/BoxContainer/StartButton

func _ready() -> void:
	_start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(SceneStateGlobal.HOME_SCENE[0])
