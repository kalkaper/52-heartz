shader_type canvas_item;

uniform float strength : hint_range(0.0, 0.1) = 0.006;
uniform float speed = 3.0;

void fragment() {
	vec2 uv = UV;
	float gust = sin(TIME * speed) * 0.5 + 0.5;
	uv.x += sin(uv.y * 20.0 + TIME * speed * 2.0) * strength * (0.5 + gust);
	uv.y += cos(uv.x * 15.0 + TIME * speed * 1.5) * strength * 0.4;
	COLOR = texture(TEXTURE, uv);
}