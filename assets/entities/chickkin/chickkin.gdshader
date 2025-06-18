shader_type spatial;
render_mode unshaded;

uniform sampler2D u_color : filter_nearest;

instance uniform float u_colorChoice = 0;
instance uniform float u_faceChoice = 0;

vec2 personaliseUV(vec2 uv) {
	if (uv.y >= 0.5) return uv;
	
	if (uv.x < 0.75) {
		uv.x += u_colorChoice * (0.75 / 6.0f);
	} else {
		uv.y += u_faceChoice * (1.0f / 4.0f);
	}
	
	return uv;
}

void fragment() {
	vec4 col = texture(u_color, personaliseUV(UV));
	if (col.a <= 0.5f)
		discard;
	ALBEDO = col.rgb;
}
