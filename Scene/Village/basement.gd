extends Area2D

@onready var Peasant = $Digger1

func _ready() -> void:
		Peasant.character_clicked.connect(
		DialogueManager.start_dialogue
		)
