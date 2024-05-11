extends KinematicBody2D
class_name KinematicActor

export (float) var base_speed := 128.0
export (float, 0.0, 0.99) var steering := 0.0

var direction : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

func get_walk_velocity() -> Vector2:
	var new_velocity : Vector2 = direction * base_speed
	
	return velocity.linear_interpolate(new_velocity, 1.0 - steering)
	
func _physics_process(delta):
	velocity = get_walk_velocity()
	
	velocity = move_and_slide(velocity, Vector2.ZERO)
