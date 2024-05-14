shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = (color.rgb + COLOR.rgb) - 2.0 * (color.rgb * COLOR.rgb);
}