extends Area2D

@onready var Merc: Mercenary = $Mercenary

func _ready() -> void:
		Merc.character_clicked.connect(
		DialogueManager.start_dialogue
		)
