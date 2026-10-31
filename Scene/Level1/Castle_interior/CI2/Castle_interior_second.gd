extends Node2D

const DECREE_READER_SCENE := preload("res://Scene/Level1/Castle_interior/CI2/decree_reader.tscn")

@onready var DecreeBoard := $DecreeBoard
@onready var mode_switch := $ModeSwitch


func _ready() -> void:

	DecreeBoard.board_clicked.connect(_on_DecreeBoard_clicked)
	SupportingSceneManager.opened.connect(func(): mode_switch.set_ui_visible(false))
	SupportingSceneManager.closed.connect(func(): mode_switch.set_ui_visible(true))


func _on_DecreeBoard_clicked() -> void:
	SupportingSceneManager.open(DECREE_READER_SCENE)
