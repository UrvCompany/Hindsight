extends Node2D
## Ambient overlays use normalized coordinates of the background illustration.
@export var enabled: bool = true
@export_range(0.0, 2.0) var intensity: float = 0.7
@export var smoke_enabled: bool = true
@export var birds_enabled: bool = true
@export var water_enabled: bool = true

var _time: float = 0.0
var _puff: GradientTexture2D
@onready var _background: Sprite2D = get_parent() as Sprite2D
const CHIMNEYS: Array[Vector2] = [Vector2(0.327, 0.647), Vector2(0.405, 0.663), Vector2(0.241, 0.582)]
var water_polygon: PackedVector2Array = PackedVector2Array([
	Vector2(0.281, 0.566), Vector2(0.282, 0.578), Vector2(0.297, 0.596),
	Vector2(0.329, 0.627), Vector2(0.362, 0.646), Vector2(0.387, 0.665),
	Vector2(0.360, 0.671), Vector2(0.338, 0.656), Vector2(0.325, 0.641),
	Vector2(0.298, 0.619), Vector2(0.281, 0.601), Vector2(0.269, 0.587)])

func _ready() -> void:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([Color(0.75, 0.73, 0.68, 0.7), Color(0.75, 0.73, 0.68, 0.0)])
	_puff = GradientTexture2D.new()
	_puff.gradient = gradient
	_puff.width = 64
	_puff.height = 64
	_puff.fill = GradientTexture2D.FILL_RADIAL
	_puff.fill_from = Vector2(0.5, 0.5)
	_puff.fill_to = Vector2(0.5, 0.0)

func _process(delta: float) -> void:
	if enabled and is_visible_in_tree():
		_time += delta
	queue_redraw()

func _point(uv: Vector2) -> Vector2:
	return _background.get_rect().position + uv * _background.get_rect().size

func _draw() -> void:
	if not enabled or intensity <= 0.0 or _background == null or _puff == null:
		return
	var size: Vector2 = _background.get_rect().size
	if smoke_enabled:
		for chimney in CHIMNEYS:
			for i in range(9):
				var age: float = fposmod(_time * 0.27 + float(i) / 9.0 + chimney.x, 1.0)
				var uv: Vector2 = chimney + Vector2(age * 0.018 + sin(age * 8.0 + _time * 0.35) * age * 0.003, -age * 0.12)
				var radius: float = lerpf(0.0025, 0.05, age) * size.x
				var fade: float = sin(age * PI) * intensity * 1.0
				draw_texture_rect(_puff, Rect2(_point(uv) - Vector2.ONE * radius, Vector2.ONE * radius * 2.0), false, Color(1, 1, 1, fade))
	if birds_enabled:
		for i in range(5):
			var phase: float = float(i)
			var progress: float = fposmod(_time * 0.009 + 0.24, 1.0)
			var uv := Vector2(lerpf(-0.08, 1.08, progress) - phase * 0.012, 0.20 + sin(progress * TAU) * 0.035 + absf(phase - 2.0) * 0.009)
			var center: Vector2 = _point(uv)
			var wing: float = sin(_time * 4.0 + phase * 0.8) * size.y * 0.0025
			var span: float = size.x * 0.003
			draw_polyline(PackedVector2Array([center + Vector2(-span, -wing), center, center + Vector2(span, -wing)]), Color(0.15, 0.19, 0.22, minf(intensity * 0.7, 1.0)), 1.1, true)
	if water_enabled:
		for i in range(48):
			var seed_value: float = float(i)
			var uv := Vector2(lerpf(0.27, 0.39, fposmod(seed_value * 0.618, 1.0)), lerpf(0.566, 0.671, fposmod(seed_value * 0.381 + _time * 0.007, 1.0)))
			if not Geometry2D.is_point_in_polygon(uv, water_polygon):
				continue
			var alpha: float = pow(maxf(0.0, sin(_time * 1.6 + seed_value * 2.4)), 4.0) * 0.24 * intensity
			var center: Vector2 = _point(uv)
			var width: float = size.x * 0.002
			draw_line(center - Vector2(width, 0), center + Vector2(width, 0), Color(0.92, 0.88, 0.70, alpha), 1.0, true)
