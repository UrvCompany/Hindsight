extends Node2D


const CROCODILE_CAGE_VIEW_SCENE := preload("res://Scene/Castle_wall/CW2/crocodile_cage_view.tscn")
const DIALOGUE_BOX_SCENE := preload("res://UI/DialogueBox/DialogueBox.tscn")



@onready var crocodile_cage: CrocodileCage = $"СrocodileСage"
@onready var dialogue_box: DialogueBox = $"DialogueBox"
@onready var guard: Guard = $"Guard2"

func _ready() -> void:
	crocodile_cage.cage_clicked.connect(_on_crocodile_cage_clicked)
		
	guard.guard_clicked.connect(_guard_clicked)
	
	
	

func _on_crocodile_cage_clicked() -> void:
	SupportingSceneManager.open(CROCODILE_CAGE_VIEW_SCENE)

func _guard_clicked():
	print('Открытие диалога')
	SupportingSceneManager.open(DIALOGUE_BOX_SCENE)
