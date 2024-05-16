tool
extends Line2D

func _process(delta):
	var base_angle : float = get_parent().get("base_angle")
	
	if base_angle != null:
		rotation = deg2rad(base_angle)
