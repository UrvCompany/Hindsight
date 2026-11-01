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
	Vector2(1037,599),Vector2(1038,561),Vector2(1028,555),Vector2(1064,543),
	Vector2(1115,461),Vector2(1155,458),Vector2(1154,440),Vector2(1177,440),
	Vector2(1178,459),Vector2(1229,454),Vector2(1241,470),Vector2(1307,475),
	Vector2(1307,483),Vector2(1301,484),Vector2(1301,532),Vector2(1261,532),
	Vector2(1261,496),Vector2(1248,491),Vector2(1252,516),Vector2(1270,544),
	Vector2(1306,550),Vector2(1355,552),Vector2(1366,560),Vector2(1365,613),
	Vector2(1356,625),Vector2(1305,633),Vector2(1250,628),Vector2(1214,617),
	Vector2(1170,618),Vector2(1135,613),Vector2(1105,605),Vector2(1064,608),Vector2(1037,599)
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

