shader_type canvas_item;

uniform float wave_strength : hint_range(0.0, 0.05) = 0.012;
uniform float wave_speed = 1.2;
uniform float wave_scale = 14.0;
uniform vec4 tint : source_color = vec4(0.25, 0.55, 0.8, 1.0);
uniform float tint_amount : hint_range(0.0, 1.0) = 0.35;
uniform float caustic_strength : hint_range(0.0, 1.0) = 0.25;

void fragment() {
	vec2 uv = UV;
	// wobble, like looking through water
	uv.x += sin(uv.y * wave_scale + TIME * wave_speed) * wave_strength;
	uv.y += cos(uv.x * wave_scale * 0.8 + TIME * wave_speed * 0.8) * wave_strength;
	vec4 col = texture(TEXTURE, uv);
	// blue tint
	col.rgb = mix(col.rgb, col.rgb * tint.rgb * 1.4, tint_amount);
	// moving light bands
	float c = sin((uv.x + uv.y) * 18.0 + TIME * 1.5) * sin((uv.x - uv.y) * 14.0 - TIME * 1.1);
	col.rgb += max(c, 0.0) * caustic_strength * 0.25 * tint.rgb;
	// dark edges
	float vignette = smoothstep(0.9, 0.3, distance(UV, vec2(0.5)));
	col.rgb *= mix(0.6, 1.0, vignette);
	COLOR = col;
}