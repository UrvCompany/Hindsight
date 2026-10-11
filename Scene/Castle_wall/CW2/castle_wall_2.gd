
extends Node2D

const CROCODILE_CAGE_VIEW_SCENE: PackedScene = preload(
    "res://Scene/Castle_wall/CW2/crocodile_cage_view.tscn"
)

@onready var crocodile_cage: CrocodileCage = $"СrocodileСage"
@onready var guard: Guard = $"Guard2"


func _ready() -> void:
	crocodile_cage.cage_clicked.connect(
		_on_crocodile_cage_clicked
		)

	guard.character_clicked.connect(
		DialogueManager.start_dialogue
		)


func _on_crocodile_cage_clicked() -> void:
	SupportingSceneManager.open(CROCODILE_CAGE_VIEW_SCENE)
