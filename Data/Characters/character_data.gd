
extends Resource
class_name CharacterData


@export var id: String
@export var display_name: String
@export var portrait: Texture2D

@export_group("Dynamic Name")
@export var dynamic_names: Array[DynamicName] = []


func get_display_name() -> String:
	for rule: DynamicName in dynamic_names:
		if rule == null:
			continue

		if (
			SceneStateGlobal.CURRENT_LEVEL == rule.level
			and SceneStateGlobal.STAGE == rule.stage
		):
			return rule.display_name

	return display_name
