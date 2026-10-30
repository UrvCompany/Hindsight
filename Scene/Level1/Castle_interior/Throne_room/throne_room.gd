extends Node2D

@onready var king: King = $"King"

func _ready() -> void:

	king.character_clicked.connect(
		DialogueManager.start_dialogue
		)
