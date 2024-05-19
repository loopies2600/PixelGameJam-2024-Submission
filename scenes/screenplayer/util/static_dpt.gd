extends StaticBody2D

func _process(_delta):
	z_index = int(clamp(get_global_transform_with_canvas().origin.y, 0, VisualServer.CANVAS_ITEM_Z_MAX))
