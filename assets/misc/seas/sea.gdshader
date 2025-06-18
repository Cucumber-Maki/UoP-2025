shader_type spatial;
render_mode unshaded;

uniform float foamScale = 20.0;
uniform sampler2D foamShape : filter_nearest, repeat_enable;
uniform float timeScale = 0.01;

uniform vec3 waterColor : source_color = vec3(0, 0, 1.0);
uniform vec3 foamColor : source_color = vec3(1.0, 1.0, 1.0);

vec2 getUVOffset(vec2 baseUV, float t) {
	// Pirated from https://medium.com/@gordonnl/the-ocean-170fdfd659f1 -- ty MIT license <3
	vec2 uv = baseUV * 10.0 + vec2(t * -0.05);
    uv.y += 0.01 * (sin(uv.x * 3.5 + t * 0.35) + sin(uv.x * 4.8 + t * 1.05) + sin(uv.x * 7.3 + t * 0.45)) / 3.0;
    uv.x += 0.12 * (sin(uv.y * 4.0 + t * 0.5) + sin(uv.y * 6.8 + t * 0.75) + sin(uv.y * 11.3 + t * 0.2)) / 3.0;
    uv.y += 0.12 * (sin(uv.x * 4.2 + t * 0.64) + sin(uv.x * 6.3 + t * 1.65) + sin(uv.x * 8.2 + t * 0.45)) / 3.0;
	return uv;
}

void fragment() {
	float foamFactor = texture(foamShape, getUVOffset(UV * foamScale, TIME * timeScale)).r;
	ALBEDO = mix(waterColor, foamColor, foamFactor);
}