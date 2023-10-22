shader_type spatial;

uniform vec3 color : source_color;
uniform sampler2D noise_tex : hint_default_transparent, filter_nearest;

void fragment() {
//	ALBEDO = color.rgb - (texture(noise_tex, UV).rgb);
	ALBEDO = color.rgb;
	NORMAL =  NORMAL - (texture(noise_tex, UV).rgb);
}
