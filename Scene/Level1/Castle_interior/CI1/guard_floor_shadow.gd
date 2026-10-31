extends Node2D
## Local to the guard, so moving or mirroring him keeps the shadow at his feet.
@export_range(0.0, 1.0) var shadow_opacity: float = 0.9
@export_range(0.0, 12.0) var sway_amount: float = 3.0
@export_range(0.0, 0.3) var flicker_amount: float = 0.25
@export_range(-200.0, 200.0, 1.0) var feet_offset_y: float = 0.0

var _elapsed: float = 0.0
var _soft_shadow: GradientTexture2D
var _feet := Vector2.ZERO
var _width: float = 95.0

func _ready() -> void:
	show_behind_parent = true
	var sprite := get_parent().get_node("Sprite2D") as Sprite2D
	var image: Image = sprite.texture.get_image()
	var used: Rect2i = image.get_used_rect()
	var bottom: Vector2 = Vector2(used.position.x + used.size.x * 0.5, used.end.y - 5.0)
	
	_feet = sprite.transform * (sprite.get_rect().position + bottom)
	_feet.y += feet_offset_y
	
	_width = float(used.size.x) * absf(sprite.scale.x) * 0.70
	var gradient := Gradient.new()
	gradient.offsets = PackedFloat32Array([0.0, 0.35, 0.7, 1.0])
	gradient.colors = PackedColorArray([Color(0.025,0.018,0.014,1.0),Color(0.025,0.018,0.014,0.65),Color(0.025,0.018,0.014,0.18),Color(0.025,0.018,0.014,0.0)])
	_soft_shadow = GradientTexture2D.new()
	_soft_shadow.gradient = gradient
	_soft_shadow.width = 128
	_soft_shadow.height = 128
	_soft_shadow.fill = GradientTexture2D.FILL_RADIAL
	_soft_shadow.fill_from = Vector2(0.5,0.5)
	_soft_shadow.fill_to = Vector2(1.0,0.5)

func _process(delta: float) -> void:
	_elapsed += delta
	queue_redraw()

func _draw() -> void:
	if _soft_shadow == null:
		return

	var sway: float = (
		sin(_elapsed * 1.35) * sway_amount
		+ sin(_elapsed * 2.17) * sway_amount * 0.25
	)

	var flicker: float = (
		sin(_elapsed * 3.7 + 0.4) * 0.48
		+ sin(_elapsed * 7.3 + 0.84) * 0.27
		+ sin(_elapsed * 11.1 + 0.28) * 0.14
	)

	var opacity: float = clampf(
		shadow_opacity - flicker * flicker_amount,
		0.0,
		1.0
	)

	# Основная тень
	draw_set_transform(
		_feet + Vector2(sway, 0.0),
		-0.12 + sway * 0.004
	)

	draw_texture_rect(
		_soft_shadow,
		Rect2(
			Vector2(-_width * 0.85, -24.0),
			Vector2(_width * 1.7, 48.0)
		),
		false,
		Color(1, 1, 1, opacity)
	)

	# Контактная тень
	draw_set_transform(_feet)

	draw_texture_rect(
		_soft_shadow,
		Rect2(
			Vector2(-_width * 0.52, -9.0),
			Vector2(_width * 1.04, 18.0)
		),
		false,
		Color(1, 1, 1, shadow_opacity * 0.85)
	)

	## Сбрасываем трансформацию
	#draw_set_transform(Vector2.ZERO)
#
	## Отображаем положение ног
	#draw_circle(_feet, 8.0, Color.RED)
