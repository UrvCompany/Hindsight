extends Resource
class_name DialogueData

@export var dialogue_id: String
@export var character: CharacterData
@export var lines: Array[DialogueLine] = []
@export var choices: Array[DialogueChoice] = []
