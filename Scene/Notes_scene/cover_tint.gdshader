shader_type canvas_item;
uniform vec4 cover_color : source_color = vec4(0.30, 0.07, 0.09, 1.0);
void fragment() {
	vec4 c = texture(TEXTURE, UV);
	float blue = smoothstep(0.015, 0.08, c.b - c.r) * smoothstep(0.0, 0.035, c.b - c.g);
	float light = max(c.r, max(c.g, c.b));
	c.rgb = mix(c.rgb, cover_color.rgb * (0.4 + light * 2.5), blue);
	COLOR = c;
}
