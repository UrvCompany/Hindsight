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
var OUTLINE: PackedVector2Array = PackedVector2Array()
func _ready() -> void:
	var board := get_parent().get_node("BoardArtwork") as Polygon2D
	# Cancel the object's scale so dash spacing and width match the other hints.
	var object_scale: Vector2 = get_parent().scale
	scale = Vector2.ONE / object_scale
	for point in board.polygon:
		OUTLINE.append((board.transform * point) * object_scale)
	if not OUTLINE.is_empty():
		OUTLINE.append(OUTLINE[0])
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

