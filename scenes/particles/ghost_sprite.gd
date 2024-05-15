extends Sprite

export (float) var lifetime := 0.5
export (int) var base_z_index := 0

var elapsed := 0.0

onready var mat : ShaderMaterial = material as ShaderMaterial

func _process(delta):
	elapsed += delta
	
	z_index = base_z_index + max(get_global_transform_with_canvas().origin.y, 0)
	
	mat.set_shader_param("opacity", (lifetime - elapsed) / lifetime)
	
	if elapsed >= lifetime:
		queue_free()
