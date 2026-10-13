
extends Resource
class_name DialogueRule

@export var character: CharacterData
@export var dialogue: DialogueData
@export var priority: int = 0
@export var conditions: Array[DialogueCondition] = []



func matches(character_data: CharacterData) -> bool:
	print("Проверка правила: ", resource_path)

	if character == null or dialogue == null:
		print("Выход: character или dialogue не назначен")
		return false

	if character_data == null:
		print("Выход: character_data == null")
		return false

	print("ID правила: ", character.id)
	print("ID переданного персонажа: ", character_data.id)

	if character.id != character_data.id:
		print("Выход: ID персонажей не совпадают")
		return false

	print("Количество условий: ", conditions.size())

	for condition: DialogueCondition in conditions:
		if condition == null:
			print("Выход: условие == null")
			return false

		print("Вызов is_satisfied(): ", condition.type)

		if not condition.is_satisfied():
			print("Выход: условие не выполнено")
			return false

	print("Правило подходит")
	return true
