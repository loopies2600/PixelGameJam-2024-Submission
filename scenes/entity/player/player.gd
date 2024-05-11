extends KinematicActor

var input_direction : Vector2 = Vector2.ZERO

func _process(delta):
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	direction = input_direction
