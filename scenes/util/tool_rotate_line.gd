tool
extends Line2D

func _ready():
	if not Engine.editor_hint:
		hide()
		
func _process(delta):
	var base_angle : float = get_parent().get("base_angle")
	
	if base_angle != null:
		rotation = deg2rad(base_angle)
