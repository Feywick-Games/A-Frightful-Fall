shader_type spatial;

render_mode unshaded;

uniform sampler2D noise_tex_normal : filter_nearest;
uniform sampler2D noise_tex : filter_nearest;
uniform float progress : hint_range(0.0, 1.0);
uniform float strength = 1.0;
uniform sampler2D sprite : hint_default_transparent, filter_nearest;
uniform float uv_x_scale;

void vertex() {
	
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
	MODELVIEW_NORMAL_MATRIX = mat3(MODELVIEW_MATRIX);
}



void fragment() {
	vec2 direction = texture(noise_tex_normal, UV).xy; // We're using normal map as direction
	direction -= 0.5; // Since our normal map is a texture, it ranges from 0.0 to 1.0...
	direction *= 2.0; // ...so we're going to make it range from -1.0 to 1.0.
	direction = direction * strength * progress;
	
	// UV for exploded texture
	vec2 tex_size = vec2(1088.0,64.0); // Real texture size in pixels
	vec2 uv = floor(UV * tex_size) / (tex_size - 1.0); // Pixelate UV to snap pixels
	uv = uv - direction; // Distort UV
	
	// Texture with exploded UV
	vec4 tex = texture(sprite, uv); 
	
	// Dissolve alpha
	float dissolve = texture(noise_tex, UV).x;
	dissolve = step(progress, dissolve);
	tex.a *= dissolve;
	
	// Border (in case the edge of your sprite stretches, otherwise you can remove this block)
//	vec2 border_uv = uv * 2.0 - 1.0;
//	border_uv = clamp(abs(border_uv), 0.0, 1.0);
//	float border = max(border_uv.x, border_uv.y);
//	border = ceil(1.0 - border);
//	tex.a *= border;
	
	ALBEDO = tex.rgb;
	ALPHA = tex.a;
}