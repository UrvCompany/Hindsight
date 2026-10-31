shader_type canvas_item;
render_mode unshaded;
uniform float animation_time = 0.0;
uniform float flame_strength : hint_range(0.0, 2.0) = 1.0;
uniform float light_strength : hint_range(0.0, 2.0) = 0.8;
uniform float shadow_strength : hint_range(0.0, 2.0) = 0.7;

float flicker(float t, float phase) {
	return sin(t * 3.7 + phase) * 0.48 + sin(t * 7.3 + phase * 2.1) * 0.27 + sin(t * 11.1 + phase * 0.7) * 0.14;
}

vec2 flame_offset(vec2 p, vec2 source, float phase, float width) {
	vec2 q = p - source;
	float mask = (1.0 - smoothstep(width * 0.4, width, abs(q.x))) * smoothstep(-55.0, -40.0, q.y) * (1.0 - smoothstep(12.0, 25.0, q.y));
	float height = clamp((22.0 - q.y) / 68.0, 0.0, 1.0);
	float sway = sin(animation_time * 5.1 + q.y * 0.12 + phase) + 0.45 * sin(animation_time * 8.3 + q.y * 0.18 + phase);
	return vec2(sway * 2.5 * height, flicker(animation_time, phase) * height * 2.0) * mask * flame_strength;
}

float light_field(vec2 p, vec2 source) {
	vec2 d = (p - source) / vec2(265.0, 320.0);
	return exp(-dot(d,d) * 1.5);
}

float shadow_field(vec2 p, vec2 source, float phase) {
	vec2 d = p - source;
	float drift = sin(animation_time * 1.7 + phase) * 0.025 + flicker(animation_time, phase) * 0.012;
	float angle = atan(d.y, d.x);
	float bands = pow(0.5 + 0.5 * sin((angle + drift) * 9.0 + phase), 5.0);
	float distance_fade = smoothstep(45.0, 160.0, length(d)) * exp(-length(d) / 470.0);
	return bands * distance_fade;
}

void fragment() {
	vec2 p = UV * vec2(1669.0, 942.0);
	vec2 left = vec2(425.0, 523.0);
	vec2 right = vec2(1170.0, 523.0);
	vec2 wall = vec2(1440.0, 242.0);
	vec2 offset = flame_offset(p,left,0.4,52.0) + flame_offset(p,right,2.7,52.0) + flame_offset(p,wall,4.9,26.0);
	vec4 base = texture(TEXTURE, UV + offset / vec2(1669.0,942.0));
	float a = flicker(animation_time,0.4);
	float b = flicker(animation_time,2.7);
	float c = flicker(animation_time,4.9);
	float illumination = light_field(p,left) * a + light_field(p,right) * b + light_field(p,wall) * c;
	vec3 lit = base.rgb * (1.0 + illumination * 0.13 * light_strength);
	lit += vec3(0.026,0.012,0.002) * illumination * light_strength;
	float shadows = shadow_field(p,left,0.4) * (0.65 - a * 0.25) + shadow_field(p,right,2.7) * (0.65 - b * 0.25);
	shadows += shadow_field(p,wall,4.9) * (0.65 - c * 0.25);
	lit *= 1.0 - shadows * 0.18 * shadow_strength;
	COLOR = vec4(lit,base.a);
}

