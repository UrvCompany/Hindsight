
extends Resource
class_name DialogueRule

@export var character: CharacterData
@export var dialogue: DialogueData
@export var priority: int = 0
@export var conditions: Array[DialogueCondition] = []


func matches(character_data: CharacterData) -> bool:
	if character == null or dialogue == null:
		return false

	if character_data == null:
		return false

	if character.id != character_data.id:
		return false

	for condition: DialogueCondition in conditions:
		if condition == null:
			return false

		if not condition.is_satisfied():
			return false

	return true
