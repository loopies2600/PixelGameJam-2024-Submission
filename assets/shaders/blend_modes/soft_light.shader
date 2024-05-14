shader_type canvas_item;

uniform vec4 color : hint_color = vec4(1.0);
uniform float maximum : hint_range(0.0, 1.0) = 0.5;

void fragment() {
	COLOR = texture(SCREEN_TEXTURE, SCREEN_UV);
	
	vec4 limit = step(maximum, COLOR);
	COLOR = mix(2.0 * COLOR * color + COLOR * COLOR * (1.0 - 2.0 * color), sqrt(COLOR) * (2.0 * color - 1.0) + (2.0 * COLOR) * (1.0 - color), limit);
}