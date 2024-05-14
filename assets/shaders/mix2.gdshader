shader_type canvas_item;

uniform sampler2D texA : hint_white;
uniform sampler2D texB : hint_black;

uniform float amount : hint_range(0.0, 1.0, 0.1) = 0.0;

void fragment() {
	vec4 colA = texture(texA, UV);
	vec4 colB = texture(texB, UV);
	
	COLOR = mix(colA, colB, amount);
}