extends StaticBody2D

func _process(_delta):
	z_index = int(max(get_global_transform_with_canvas().origin.y, 0))
