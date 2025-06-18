shader_type canvas_item;

uniform float circle_size = 0.5f;

void fragment() {
	// Called for every pixel the material is visible on.
		if (distance(vec2(0.5, 0.5), UV) < circle_size) {
		COLOR.a = 0.f;
	}
}