extends Node2D
## Small water-only patches leave roofs, banks and foreground trees still.
@export var enabled: bool = true
@export_range(0.0, 2.0) var wave_strength: float = 1.8
@export_range(0.0, 2.0) var glint_strength: float = 0.55
@export_range(0.0, 3.0) var flow_speed: float = 1.0
@export_range(0.0, 5.0) var swell_amplitude: float = 1.6
@export_range(12.0, 160.0) var swell_length: float = 42.0
@export var flow_direction: Vector2 = Vector2(1.0, 0.28)
@export var water_shader: Shader
var elapsed: float = 0.0
var _material: ShaderMaterial

func _ready() -> void:
	var background := get_parent() as Sprite2D
	position = background.get_rect().position
	scale = background.get_rect().size / Vector2(1670,942)
	_material = ShaderMaterial.new()
	_material.shader = water_shader
	# Reference positions in the clean background plate, clockwise banks.
	var patches: Array[PackedVector2Array] = [
		PackedVector2Array([Vector2(676,499),Vector2(723,494),Vector2(694,512),Vector2(651,524),Vector2(619,543),Vector2(623,557),Vector2(668,575),Vector2(747,593),Vector2(794,605),Vector2(650,608),Vector2(565,626),Vector2(481,661),Vector2(461,675),Vector2(433,650),Vector2(413,625),Vector2(394,610),Vector2(382,579),Vector2(432,561),Vector2(498,541),Vector2(558,523),Vector2(615,512)]),
		PackedVector2Array([Vector2(719,668),Vector2(733,680),Vector2(734,699),Vector2(753,711),Vector2(792,718),Vector2(815,712),Vector2(820,695),Vector2(846,706),Vector2(898,716),Vector2(966,731),Vector2(1027,741),Vector2(1046,753),Vector2(1116,756),Vector2(1132,744),Vector2(1169,750),Vector2(1210,760),Vector2(1263,764),Vector2(1301,766),Vector2(1314,780),Vector2(1289,794),Vector2(1246,809),Vector2(1202,835),Vector2(1157,857),Vector2(1104,874),Vector2(1020,855),Vector2(936,836),Vector2(872,813),Vector2(823,798),Vector2(761,775),Vector2(709,751),Vector2(684,733),Vector2(685,702),Vector2(700,682)]),
		PackedVector2Array([Vector2(677,466),Vector2(713,461),Vector2(721,470),Vector2(704,475),Vector2(679,475)])
	]
	for outline in patches:
		_add_patch(outline, background.texture)

func _add_patch(outline: PackedVector2Array, texture: Texture2D) -> void:
	var center := Vector2.ZERO
	for point in outline:
		center += point
	center /= float(outline.size())
	var vertices := PackedVector2Array(outline)
	var colors := PackedColorArray()
	var inner := PackedVector2Array()
	for point in outline:
		colors.append(Color(1,1,1,0))
		inner.append(point.move_toward(center, 3.0))
	vertices.append_array(inner)
	for point in inner:
		colors.append(Color.WHITE)
	var faces: Array[PackedInt32Array] = []
	var count: int = outline.size()
	for i in range(count):
		var next: int = (i + 1) % count
		faces.append(PackedInt32Array([i,next,count+next]))
		faces.append(PackedInt32Array([i,count+next,count+i]))
	var triangles: PackedInt32Array = Geometry2D.triangulate_polygon(inner)
	for i in range(0,triangles.size(),3):
		faces.append(PackedInt32Array([count+triangles[i],count+triangles[i+1],count+triangles[i+2]]))
	var patch := Polygon2D.new()
	patch.polygon = vertices
	var texture_uv := PackedVector2Array()
	for point in vertices:
		texture_uv.append(point * texture.get_size() / Vector2(1670,942))
	patch.uv = texture_uv
	patch.vertex_colors = colors
	patch.polygons = faces
	patch.texture = texture
	patch.material = _material
	add_child(patch)

func _process(delta: float) -> void:
	visible = enabled
	if not enabled:
		return
	elapsed += delta * flow_speed
	_material.set_shader_parameter("water_time", elapsed)
	_material.set_shader_parameter("strength", wave_strength)
	_material.set_shader_parameter("glint_strength", glint_strength)

	_material.set_shader_parameter("swell_amplitude", swell_amplitude)
	_material.set_shader_parameter("swell_length", swell_length)
	_material.set_shader_parameter("flow_direction", flow_direction)

