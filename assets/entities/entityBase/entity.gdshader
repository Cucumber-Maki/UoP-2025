shader_type spatial;
render_mode unshaded;

uniform sampler2D u_color : filter_nearest;

void fragment() {
	vec4 col = texture(u_color, UV);
	if (col.a <= 0.5f)
		discard;
	ALBEDO = col.rgb;
}
