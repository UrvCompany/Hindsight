extends Node

const CATALOG = preload("res://Data/Endings/ending_catalog.gd")
var current_ending: EndingRequest

func show_ending(request: EndingRequest) -> Error:
	if CATALOG.resolve(request) == null:
		return ERR_DOES_NOT_EXIST
	var viewer := load("res://Scene/Level_Ending_Scenes/LevelEnding.tscn") as PackedScene
	if viewer == null:
		return ERR_CANT_OPEN
	var previous := current_ending
	current_ending = request.duplicate() as EndingRequest
	var error := get_tree().change_scene_to_packed(viewer)
	if error != OK:
		current_ending = previous
	return error
