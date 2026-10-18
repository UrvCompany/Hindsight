extends Resource
class_name DialogueCondition

enum ConditionType {
	LEVEL_EQUALS,
	STAGE_EQUALS,
	FLAG_EQUALS,
	ITEM_OWNED,
	CHARACTER_MET,
	QUEST_COMPLETED
}

@export var type: ConditionType
@export var key: String = ""
@export var number_value: int = 0
@export var expected: bool = true


func is_satisfied() -> bool:
	match type:
		ConditionType.LEVEL_EQUALS:
			return SceneStateGlobal.CURRENT_LEVEL == number_value

		ConditionType.STAGE_EQUALS:
			return SceneStateGlobal.STAGE == number_value

		ConditionType.FLAG_EQUALS:
			return SceneStateGlobal.has_flag(key) == expected

		ConditionType.ITEM_OWNED:
			return SceneStateGlobal.has_item(key) == expected

		ConditionType.CHARACTER_MET:
			return SceneStateGlobal.has_met_character(key) == expected

		ConditionType.QUEST_COMPLETED:
			return SceneStateGlobal.is_quest_completed(key) == expected

	return false
