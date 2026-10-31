shader_type canvas_item;
render_mode unshaded;
uniform float water_time = 0.0;
uniform float strength : hint_range(0.0, 2.0) = 0.8;
uniform float glint_strength : hint_range(0.0, 2.0) = 0.7;
// Defaults preserve the original General river.
uniform float swell_amplitude : hint_range(0.0, 5.0) = 0.0;
uniform float swell_length : hint_range(12.0, 160.0) = 65.0;
uniform vec2 flow_direction = vec2(1.0, 0.28);
varying float edge;
void vertex() { edge = COLOR.a; }
void fragment() {
	vec2 p = UV / TEXTURE_PIXEL_SIZE;
	float wave = sin(p.y * 0.74 + p.x * 0.035 - water_time * 1.8);
	float cross_wave = sin(p.y * 1.21 - p.x * 0.06 + water_time * 1.15);
	vec2 shift = vec2(wave * 0.65, cross_wave * 0.32) * strength * edge;
	vec2 direction = normalize(flow_direction + vec2(0.00001));
	vec2 across = vec2(-direction.y, direction.x);
	float along = dot(p, direction);
	float sideways = dot(p, across);
	float swell = sin(along * 6.283185 / swell_length - water_time * 0.85 + sin(sideways * 0.075) * 0.6);
	float secondary = sin(along * 6.283185 / (swell_length * 0.63) - water_time * 1.15 + sideways * 0.045);
	// Move painted reflections downstream; soften motion at the patch boundary.
	float depth = mix(0.35, 1.0, smoothstep(450.0, 690.0, p.y));
	shift += (direction * (swell + secondary * 0.28) + across * secondary * 0.18) * swell_amplitude * strength * depth * edge;
	vec4 river = texture(TEXTURE, UV + shift * TEXTURE_PIXEL_SIZE);
	float broken = pow(max(0.0, sin(p.x * 0.24 + sin(p.y * 0.16) * 2.0 + water_time * 0.6)), 8.0);
	float crest = pow(max(0.0, wave * 0.65 + cross_wave * 0.35), 10.0);
	float shimmer = crest * broken * glint_strength;
	river.rgb += vec3(0.22, 0.21, 0.16) * shimmer;
	river.rgb *= 1.0 + wave * cross_wave * 0.022 * strength;
	COLOR = vec4(river.rgb, edge);
}

