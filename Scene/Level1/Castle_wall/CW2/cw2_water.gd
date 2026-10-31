extends Node2D
## Small water-only patches leave roofs, banks and foreground trees still.
@export var enabled: bool = true
@export_range(0.0, 2.0) var wave_strength: float = 1.8
@export_range(0.0, 2.0) var glint_strength: float = 1.0
@export_range(0.0, 3.0) var flow_speed: float = 1.0
@export_range(0.0, 5.0) var swell_amplitude: float = 1.8
@export_range(12.0, 160.0) var swell_length: float = 26.0
@export var flow_direction: Vector2 = Vector2(-0.7, 0.7)
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
		PackedVector2Array([Vector2(523,498),Vector2(541,497),Vector2(550,504),Vector2(545,516),Vector2(530,527),Vector2(512,536),Vector2(503,532),Vector2(505,522),Vector2(526,513),Vector2(530,505)]),
		PackedVector2Array([Vector2(440,527),Vector2(477,522),Vector2(480,535),Vector2(472,548),Vector2(474,558),Vector2(452,564),Vector2(438,555),Vector2(430,542),Vector2(412,539)])
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


