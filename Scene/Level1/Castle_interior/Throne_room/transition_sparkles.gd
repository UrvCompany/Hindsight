extends Node2D
## Visual only: no input handlers or collision objects.
@export var enabled: bool = true
@export_range(1, 20) var star_count: int = 7
@export_range(0.5, 4.0) var star_radius: float = 1.8
@export_range(0.5, 8.0) var appearance_seconds: float = 2.4
@export_range(1.0, 8.0) var hidden_multiplier: float = 3.0
@export var star_color: Color = Color(1.0, 0.82, 0.0, 0.9)
var _positions: Array[Vector2] = []
var _phases: Array[float] = []
var _durations: Array[float] = []
var _elapsed: float = 0.0

func _ready() -> void:
	var collision := get_parent().get_node("CollisionShape2D") as CollisionShape2D
	var rectangle := collision.shape as RectangleShape2D
	if rectangle == null:
		return
	# Stay comfortably inside the clickable region.
	var extent := rectangle.size * 0.42
	var rng := RandomNumberGenerator.new()
	rng.seed = 73192
	for i in range(star_count):
		var column: float = (float(i) + 0.5) / float(star_count)
		var point := Vector2(lerpf(-extent.x, extent.x, column), rng.randf_range(-extent.y, extent.y))
		_positions.append(collision.transform * point)
		var duration: float = appearance_seconds * rng.randf_range(0.85, 1.2)
		_durations.append(duration)
		_phases.append(rng.randf() * duration * (1.0 + hidden_multiplier))

func _process(delta: float) -> void:
	_elapsed += delta
	visible = enabled
	queue_redraw()

func _draw() -> void:
	for i in range(_positions.size()):
		var duration: float = _durations[i]
		var phase: float = fposmod(_elapsed + _phases[i], duration * (1.0 + hidden_multiplier))
		if phase >= duration:
			continue
		var alpha: float = pow(sin(PI * phase / duration), 2.0)
		var tint := star_color
		tint.a *= alpha
		var point: Vector2 = _positions[i]
		var glow := tint
		glow.a *= 0.12
		draw_circle(point, star_radius * 2.4, glow)
		draw_line(point - Vector2(star_radius, 0), point + Vector2(star_radius, 0), tint, 0.8, true)
		draw_line(point - Vector2(0, star_radius), point + Vector2(0, star_radius), tint, 0.8, true)
		draw_circle(point, 0.65, tint)
