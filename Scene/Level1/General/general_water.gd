extends Node2D
## Small water-only patches leave roofs, banks and foreground trees still.
@export var enabled: bool = true
@export_range(0.0, 2.0) var wave_strength: float = 1.8
@export_range(0.0, 2.0) var glint_strength: float = 1.7
@export_range(0.0, 3.0) var flow_speed: float = 1.0
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
		PackedVector2Array([Vector2(475,522),Vector2(489,522),Vector2(484,531),Vector2(471,536),Vector2(467,541),Vector2(487,543),Vector2(486,553),Vector2(446,556),Vector2(430,553),Vector2(451,543),Vector2(460,533)]),
		PackedVector2Array([Vector2(507,548),Vector2(533,553),Vector2(543,563),Vector2(540,578),Vector2(557,589),Vector2(585,596),Vector2(601,609),Vector2(631,616),Vector2(646,626),Vector2(640,636),Vector2(603,633),Vector2(582,617),Vector2(559,607),Vector2(539,594),Vector2(524,580),Vector2(512,567)]),
		PackedVector2Array([Vector2(690,635),Vector2(720,638),Vector2(743,651),Vector2(772,657),Vector2(779,670),Vector2(773,689),Vector2(758,700),Vector2(741,688),Vector2(731,673),Vector2(708,656)]),
		PackedVector2Array([Vector2(807,666),Vector2(840,671),Vector2(871,675),Vector2(900,676),Vector2(928,680),Vector2(935,686),Vector2(920,701),Vector2(893,711),Vector2(866,707),Vector2(843,707),Vector2(818,700),Vector2(800,699),Vector2(806,685)])
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
