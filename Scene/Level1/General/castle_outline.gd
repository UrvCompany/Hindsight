extends Node2D
## Dashed interaction hint, coordinates relative to the 1670 x 942 background.
@export var enabled: bool = true
@export_range(0.5, 4.0) var line_width: float = 1.3
@export_range(2.0, 20.0) var dash_length: float = 4.0
@export_range(1.0, 30.0) var gap_length: float = 16.0
@export_range(0.5, 8.0) var pulse_period: float = 3.0
@export var white_color: Color = Color(1, 1, 1, 0.95)
@export var yellow_color: Color = Color(1, 0.8, 0, 1)
@export_range(0.5, 8.0) var blink_period: float = 3.0
var elapsed: float = 0.0
const OUTLINE = [
	Vector2(975,523),Vector2(977,456),Vector2(970,455),Vector2(982,434),Vector2(994,406),
	Vector2(1006,434),Vector2(1012,445),Vector2(1022,414),Vector2(1034,438),Vector2(1044,421),
	Vector2(1047,397),Vector2(1042,398),Vector2(1056,378),Vector2(1069,342),Vector2(1083,378),Vector2(1096,400),
	Vector2(1100,400),Vector2(1101,341),Vector2(1094,325),Vector2(1109,298),Vector2(1127,266),
	Vector2(1141,303),Vector2(1158,326),Vector2(1150,343),Vector2(1151,353),Vector2(1159,339),
	Vector2(1175,371),Vector2(1170,388),Vector2(1185,395),Vector2(1195,393),Vector2(1205,374),
	Vector2(1214,357),Vector2(1227,389),Vector2(1236,406),Vector2(1232,409),Vector2(1234,442),
	Vector2(1247,416),Vector2(1260,447),Vector2(1271,430),Vector2(1291,463),Vector2(1287,465),
	Vector2(1288,526),Vector2(1269,535),Vector2(1236,535),Vector2(1211,541),Vector2(1167,536),
	Vector2(1136,537),Vector2(1097,533),Vector2(1065,535),Vector2(1036,530),Vector2(1005,531),Vector2(975,523)
]
func _ready() -> void:
	var background := get_parent() as Sprite2D
	position = background.get_rect().position
	scale = background.get_rect().size / Vector2(1670,942)
func _process(delta: float) -> void:
	elapsed += delta
	visible = enabled
	queue_redraw()
func _draw() -> void:
	var blend: float = (1.0 - cos(elapsed * TAU / maxf(pulse_period, 0.1))) * 0.5
	var color := white_color.lerp(yellow_color, blend)
	# A fully invisible interval separates the soft appearances.
	var blink_phase: float = fposmod(elapsed / maxf(blink_period, 0.1), 1.0)
	var opacity: float = smoothstep(0.0, 0.18, blink_phase) * (1.0 - smoothstep(0.55, 0.75, blink_phase))
	color.a *= opacity
	var cycle: float = maxf(dash_length + gap_length, 0.1)
	var distance: float = 0.0
	for i in range(OUTLINE.size() - 1):
		var a: Vector2 = OUTLINE[i]
		var b: Vector2 = OUTLINE[i + 1]
		var length: float = a.distance_to(b)
		var offset: float = 0.0
		while offset < length:
			var phase: float = fposmod(distance + offset, cycle)
			var drawing: bool = phase < dash_length
			var step: float = minf((dash_length if drawing else cycle) - phase, length - offset)
			step = maxf(step, 0.001)
			if drawing:
				draw_line(a.lerp(b, offset / length), a.lerp(b, minf(offset + step, length) / length), color, line_width, true)
			offset += step
		distance += length
