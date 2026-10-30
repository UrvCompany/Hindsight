extends Resource
class_name DialogueData

@export var dialogue_id: String
@export var character: CharacterData
@export var lines: Array[DialogueLine] = []
@export var choices: Array[DialogueChoice] = []

# Optional scene opened after the last line, when there are no choices.
@export_file("*.tscn") var completion_scene_path: String = ""

# Resolve a level ending through the shared catalog.
@export var completion_ending: EndingRequest
