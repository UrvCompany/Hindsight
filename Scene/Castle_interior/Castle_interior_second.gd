extends Node2D

const DECREE_READER_SCENE := preload("res://Scene/Castle_interior/decree_reader.tscn")

@onready var decree_board := $DecreeBoard
@onready var mode_switch := $ModeSwitch


func _ready() -> void:
	decree_board.board_clicked.connect(_on_decree_board_clicked)

	SupportingSceneManager.opened.connect(func(): mode_switch.set_ui_visible(false))
	SupportingSceneManager.closed.connect(func(): mode_switch.set_ui_visible(true))


func _on_decree_board_clicked() -> void:
	SupportingSceneManager.open(DECREE_READER_SCENE)
