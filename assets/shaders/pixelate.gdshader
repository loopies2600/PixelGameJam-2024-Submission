shader_type canvas_item;

uniform float percentSize : hint_range(0.0, 100.0, 1.0) = 100.0;

void fragment()
{
	vec2 grid_uv = round(UV * percentSize) / percentSize;
	
	vec4 text = texture(TEXTURE, grid_uv);
	
	COLOR = text;
}