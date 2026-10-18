
extends Node

const DATABASE: DialogueDatabase = preload(
    "res://Data/Dialogues/dialogue_database.tres"
	)


const DIALOGUE_BOX_SCENE: PackedScene = preload(
    "res://UI/DialogueBox/DialogueBox.tscn"
	)


func get_dialogue(character_data: CharacterData) -> DialogueData:
	if character_data == null:
		return null

	var best_dialogue: DialogueData = null
	var best_priority: int = -2147483648

	for rule: DialogueRule in DATABASE.rules:
		print('character_data', character_data)
		if rule == null:
			continue

		if not rule.matches(character_data):
			print('зашли в скип')
			continue

		if rule.priority > best_priority:
			best_priority = rule.priority
			best_dialogue = rule.dialogue

	if best_dialogue == null:
		push_warning(
            "Не найден подходящий диалог для персонажа: "
			+ character_data.id
			)

	return best_dialogue


func start_dialogue(character_data: CharacterData) -> void:

	var dialogue_data: DialogueData = get_dialogue(character_data)
	if dialogue_data == null:
		return

	SupportingSceneManager.open(
		DIALOGUE_BOX_SCENE,
		dialogue_data
		)
