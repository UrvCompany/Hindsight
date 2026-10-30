extends Sprite2D
@export var animation_enabled: bool = true
@export_range(0.0, 2.0) var flame_strength: float = 1.0
@export_range(0.0, 2.0) var light_strength: float = 0.8
@export_range(0.0, 2.0) var shadow_strength: float = 0.7
@export_range(0.0, 3.0) var animation_speed: float = 1.0
var elapsed: float = 0.0

func _ready() -> void:
	# A fresh material prevents animation state leaking across scene instances.
	material = material.duplicate()

func _process(delta: float) -> void:
	if animation_enabled:
		elapsed += delta * animation_speed
	var torch_material := material as ShaderMaterial
	torch_material.set_shader_parameter("animation_time", elapsed)
	torch_material.set_shader_parameter("flame_strength", flame_strength if animation_enabled else 0.0)
	torch_material.set_shader_parameter("light_strength", light_strength if animation_enabled else 0.0)
	torch_material.set_shader_parameter("shadow_strength", shadow_strength if animation_enabled else 0.0)
