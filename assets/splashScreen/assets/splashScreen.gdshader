shader_type canvas_item;
render_mode unshaded;

vec2 getUVOffset(vec2 baseUV, float t) {
	// Pirated from https://medium.com/@gordonnl/the-ocean-170fdfd659f1 -- ty MIT license <3
	vec2 uv = baseUV;
    uv.y += 0.001 * 0.3 * (sin(uv.x * 3.5 + t * 0.35) + sin(uv.x * 4.8 + t * 1.05) + sin(uv.x * 7.3 + t * 0.45)) / 3.0;
    uv.x += 0.012 * 0.3 * (sin(uv.y * 4.0 + t * 0.5) + sin(uv.y * 6.8 + t * 0.75) + sin(uv.y * 11.3 + t * 0.2)) / 3.0;
    uv.y += 0.012 * 0.3 * (sin(uv.x * 4.2 + t * 0.64) + sin(uv.x * 6.3 + t * 1.65) + sin(uv.x * 8.2 + t * 0.45)) / 3.0;
	return uv;
}

const float rounding = 0.2;
void fragment() {
	COLOR = texture(TEXTURE, getUVOffset(UV, (round(TIME / rounding) * rounding) * 1000.0));
}
