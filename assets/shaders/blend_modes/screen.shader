shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = 1.0 - (1.0 - COLOR.rgb) * (1.0 - color.rgb);
}