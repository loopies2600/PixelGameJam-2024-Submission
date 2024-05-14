shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	COLOR.rgb = COLOR.rgb * color.rgb;
}