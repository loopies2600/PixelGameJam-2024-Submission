extends KinematicBody2D

export (float) var base_speed := 128.0

var velocity : Vector2 = Vector2.ZERO
var input_direction : Vector2 = Vector2.ZERO

func _process(delta):
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	velocity = input_direction * base_speed
	
func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2.ZERO)
