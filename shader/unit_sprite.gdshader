shader_type canvas_item;
uniform float width:hint_range(0.0, 10.0);
uniform vec4 outline_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	float alpha = 4.0 * tex_color.a;
	
	float size_x = width * 1.0 / float(textureSize(TEXTURE, 0).x);
	float size_y = width * 1.0 / float(textureSize(TEXTURE, 0).y);
	alpha -= texture(TEXTURE, UV + vec2(size_x, 0)).a;
	alpha -= texture(TEXTURE, UV + vec2(-size_x, 0)).a;
	alpha -= texture(TEXTURE, UV + vec2(0, size_y)).a;
	alpha -= texture(TEXTURE, UV + vec2(0, -size_y)).a;
	
	vec4 final_color = mix(tex_color, outline_color, clamp(alpha, 0.0, 1.0));
	COLOR = vec4(final_color.rgb, clamp(alpha + tex_color.a, 0.0, 1.0));
}
