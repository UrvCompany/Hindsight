extends Node2D
## Chimney positions in the background reference space.
@export var enabled: bool = true
@export_range(0.0, 2.0) var smoke_opacity: float = 0.65
@export_range(0.0, 3.0) var smoke_speed: float = 1.0
@export var wind: float = 12.0
var elapsed: float = 0.0
const CHIMNEYS = [Vector2(160,337), Vector2(1215,339), Vector2(1431,336), Vector2(1164,440), Vector2(950,390)]
func _ready() -> void:
	var background := get_parent() as Sprite2D
	position = background.get_rect().position
	scale = background.get_rect().size / Vector2(1670,942)
func _process(delta: float) -> void:
	elapsed += delta * smoke_speed
	visible = enabled
	queue_redraw()
func _draw() -> void:
	for chimney in range(CHIMNEYS.size()):
		for puff in range(10):
			var age: float = fposmod(elapsed * 0.13 + float(puff) / 10.0 + chimney * 0.17, 1.0)
			var origin: Vector2 = CHIMNEYS[chimney]
			var center := origin + Vector2(wind * age + sin(age * 8.0 + chimney) * age * 5.0, -age * 65.0)
			var radius: float = 2.0 + age * 11.0
			var opacity: float = sin(age * PI) * 0.022 * smoke_opacity
			for ring in range(8, 0, -1):
				draw_circle(center, radius * float(ring) / 8.0, Color(0.65, 0.64, 0.60, opacity))
