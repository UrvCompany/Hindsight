extends Area2D
class_name Basic_plane
const CORRECT_ANSWER := preload("res://Data/CorrectAnswer.gd")



@onready var Basic_plane_rich_text: RichTextLabel = $Basic_plane_rich_text
@onready var LOH: Sprite2D = $LOH


func _ready() -> void:
	LOH.visible = false
	
	Basic_plane_rich_text.bbcode_enabled = true
	Basic_plane_rich_text.modulate = Color.BLACK
	
	if SceneStateGlobal.STAGE < 2:		#Пока хз что на третьем этапе будет
		Basic_plane_rich_text.setup_text(CORRECT_ANSWER.Basic_plane[SceneStateGlobal.CURRENT_LEVEL][SceneStateGlobal.STAGE])
		print(CORRECT_ANSWER.CORRECT_ANSWERS[SceneStateGlobal.CURRENT_LEVEL][SceneStateGlobal.STAGE])
		Basic_plane_rich_text.set_correct_answers(CORRECT_ANSWER.CORRECT_ANSWERS[SceneStateGlobal.CURRENT_LEVEL][SceneStateGlobal.STAGE])
		Basic_plane_rich_text.set_loh(LOH)

	if SceneStateGlobal.STAGE == 2:		#Пока просто выводим план короны на третьем этапе
		Basic_plane_rich_text.setup_text(CORRECT_ANSWER.Basic_plane[0][0])
		Basic_plane_rich_text.set_correct_answers(CORRECT_ANSWER.CORRECT_ANSWERS[0][0])
		Basic_plane_rich_text.set_loh(LOH)
