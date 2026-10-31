shader_type canvas_item;
render_mode unshaded;
uniform float animation_time = 0.0;
uniform float flame_strength = 1.0;
uniform float light_strength = 0.8;
uniform float shadow_strength = 0.7;
void fragment() {
	vec2 p = UV * vec2(1670.0,942.0);
	vec2 q = (p - vec2(320.0,266.0)) / vec2(12.0,19.0);
	float mask = 1.0 - smoothstep(0.35,1.0,length(q));
	float flicker = sin(animation_time*7.1)*0.55 + sin(animation_time*11.7)*0.3 + sin(animation_time*3.8)*0.15;
	vec2 shift = vec2(sin(animation_time*6.2+q.y*2.0)*2.0, flicker*1.8)*mask*flame_strength;
	vec4 col = texture(TEXTURE,UV+shift/vec2(1670.0,942.0));
	float glow = exp(-dot((p-vec2(320.0,266.0))/vec2(100.0,130.0),(p-vec2(320.0,266.0))/vec2(100.0,130.0))*2.0);
	col.rgb += vec3(0.11,0.055,0.012)*flicker*glow*light_strength;
	col.rgb *= 1.0 + mask*flicker*0.15*flame_strength;
	COLOR = col;
}
