extends RefCounted

# Chapter indices start at zero. Add future chapters here.
const SCENES: Dictionary = {
	0: {
		EndingRequest.Faction.KING: {
			EndingRequest.Outcome.VICTORY: "res://Scene/Level_Ending_Scenes/Level1/king_victory_scene.tscn",
			EndingRequest.Outcome.DEFEAT: "res://Scene/Level_Ending_Scenes/Level1/king_defeat_scene.tscn",
		},
		EndingRequest.Faction.PEASANTS: {
			EndingRequest.Outcome.VICTORY: "res://Scene/Level_Ending_Scenes/Level1/peasants_victory_scene.tscn",
			EndingRequest.Outcome.DEFEAT: "res://Scene/Level_Ending_Scenes/Level1/peasants_defeat_scene.tscn",
		},
	},
}

static func resolve(request: EndingRequest) -> PackedScene:
	if request == null:
		return null
	var sides: Dictionary = SCENES.get(request.level, {})
	var outcomes: Dictionary = sides.get(request.side, {})
	var path: String = outcomes.get(request.outcome, "")
	if path.is_empty():
		push_error("Ending not found: level=%d side=%d outcome=%d" % [request.level, request.side, request.outcome])
		return null
	return load(path) as PackedScene
