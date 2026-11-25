shader_type canvas_item;

uniform bool outline_on = false;
uniform float width = 4.0;
uniform vec4 outline_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

void fragment() {
	vec4 base = texture(TEXTURE, UV);
	if (outline_on && base.a < 0.1) {
		// this pixel is see-through: look around it for a drawn pixel
		float near = 0.0;
		for (int i = 0; i < 16; i++) {
			float angle = float(i) * 6.2831853 / 16.0;
			vec2 offset = vec2(cos(angle), sin(angle)) * width * TEXTURE_PIXEL_SIZE;
			near = max(near, texture(TEXTURE, UV + offset).a);
		}
		if (near > 0.1) {
			COLOR = outline_color;
		}
	}
}