shader_type canvas_item;
render_mode unshaded;
uniform float water_time = 0.0;
uniform float strength : hint_range(0.0, 2.0) = 0.8;
uniform float glint_strength : hint_range(0.0, 2.0) = 0.7;
varying float edge;
void vertex() { edge = COLOR.a; }
void fragment() {
	vec2 p = UV / TEXTURE_PIXEL_SIZE;
	float wave = sin(p.y * 0.74 + p.x * 0.035 - water_time * 1.8);
	float cross_wave = sin(p.y * 1.21 - p.x * 0.06 + water_time * 1.15);
	vec2 shift = vec2(wave * 0.65, cross_wave * 0.32) * strength * edge;
	vec4 river = texture(TEXTURE, UV + shift * TEXTURE_PIXEL_SIZE);
	float broken = pow(max(0.0, sin(p.x * 0.24 + sin(p.y * 0.16) * 2.0 + water_time * 0.6)), 8.0);
	float crest = pow(max(0.0, wave * 0.65 + cross_wave * 0.35), 10.0);
	float shimmer = crest * broken * glint_strength;
	river.rgb += vec3(0.22, 0.21, 0.16) * shimmer;
	river.rgb *= 1.0 + wave * cross_wave * 0.022 * strength;
	COLOR = vec4(river.rgb, edge);
}
