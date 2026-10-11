
extends Resource
class_name DialogueLine

enum Emotion {
	NEUTRAL,
	HAPPY,
	ANGRY,
	SAD,
	SURPRISED,
	THINKING
	}

@export_multiline var text: String
@export var speaker: CharacterData
@export var portrait: Texture2D
@export var emotion: Emotion = Emotion.NEUTRAL
@export var sound: AudioStream
