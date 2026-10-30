extends Node2D
## Positions are in the 1670 x 942 clean plate's reference space.
@export var clouds_enabled: bool = true
@export var flags_enabled: bool = true
@export_range(0.0, 3.0) var cloud_speed: float = 1.0
@export_range(0.0, 2.0) var wind_strength: float = 0.7
@export var cloud_texture: Texture2D
var elapsed: float = 0.0
var _layers: Array[Node2D] = []
var _sky: Polygon2D
const SPEEDS: Array[float] = [0.28, 0.55, 0.9]
const FLAGS: Array[Vector4] = [Vector4(1127, 250, 42, 15), Vector4(1158, 324, 27, 11)]

func _ready() -> void:
	var background := get_parent() as Sprite2D
	position = background.get_rect().position
	scale = background.get_rect().size / Vector2(1670, 942)
	_sky = Polygon2D.new()
	_sky.name = "SkyOcclusion"
	_sky.show_behind_parent = true
	# Conservative skyline keeps clouds off mountains and masonry.
	_sky.polygon = PackedVector2Array([Vector2(0,0), Vector2(1670,0), Vector2(1670,245),
		Vector2(1570,253), Vector2(1500,242), Vector2(1410,264), Vector2(1340,267),
		Vector2(1285,290), Vector2(1225,293), Vector2(1160,305),
		Vector2(1147,307), Vector2(1127,271), Vector2(1113,308), Vector2(1088,309),
		Vector2(1036,326), Vector2(994,317), Vector2(950,310), Vector2(921,330), Vector2(880,319), Vector2(826,337),
		Vector2(747,317), Vector2(681,309), Vector2(640,288), Vector2(568,309),
		Vector2(481,285), Vector2(408,272), Vector2(354,299), Vector2(292,267),
		Vector2(220,242), Vector2(166,260), Vector2(107,253), Vector2(60,242), Vector2(0,268)])
	_sky.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
	add_child(_sky)
	if cloud_texture:
		for layer_index in range(3):
			var layer := Node2D.new()
			layer.name = "CloudLayer%d" % layer_index
			_sky.add_child(layer)
			_layers.append(layer)
			for tile_index in range(-1, 2):
				var cloud := Sprite2D.new()
				cloud.texture = cloud_texture
				cloud.centered = false
				cloud.position = Vector2(tile_index * 1850.0, [-32.0, 35.0, -105.0][layer_index])
				cloud.scale = Vector2(1850.0, [240.0, 230.0, 280.0][layer_index]) / cloud_texture.get_size()
				cloud.modulate = Color(1, 1, 1, [0.40, 0.55, 0.65][layer_index])
				layer.add_child(cloud)

func _process(delta: float) -> void:
	elapsed += delta
	_sky.visible = clouds_enabled
	for i in range(_layers.size()):
		_layers[i].position.x = fposmod(elapsed * SPEEDS[i] * cloud_speed + float(i) * 430.0, 1850.0)
	queue_redraw()

func _flag_point(flag: Vector4, u: float, bottom: bool, phase: float) -> Vector2:
	var wave: float = sin(u * 7.5 - elapsed * 3.2 + phase) * u * 3.0 * wind_strength
	var taper: float = 1.0 - 0.32 * u
	return Vector2(flag.x + u * flag.z, flag.y + u * 2.0 + wave + (flag.w * taper if bottom else 0.0))

func _draw() -> void:
	if not flags_enabled:
		return
	for index in range(FLAGS.size()):
		var flag: Vector4 = FLAGS[index]
		for strip in range(14):
			var u: float = float(strip) / 14.0
			var v: float = float(strip + 1) / 14.0
			var phase: float = float(index) * 1.7
			var shade: float = sin(u * 7.5 - elapsed * 3.2 + phase) * 0.045 * wind_strength
			var color := Color(0.36 + shade, 0.13 + shade * 0.45, 0.105 + shade * 0.3)
			draw_colored_polygon(PackedVector2Array([_flag_point(flag,u,false,phase), _flag_point(flag,v,false,phase), _flag_point(flag,v,true,phase), _flag_point(flag,u,true,phase)]), color)
		var hem := PackedVector2Array()
		for step in range(15):
			hem.append(_flag_point(flag,float(step)/14.0,false,float(index)*1.7))
		draw_polyline(hem, Color(0.55,0.28,0.18,0.65), 0.7, true)

