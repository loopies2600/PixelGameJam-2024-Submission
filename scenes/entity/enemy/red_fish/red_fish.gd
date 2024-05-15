extends KinematicActor

enum States {
	IDLE,
	PATROL_CALM,
	PATROL_ANGRY,
	CHASE,
	DASH
}

var current_state : int = States.IDLE

func _process(delta):
	match current_state:
		States.IDLE:
			velocity.y = sin(elapsed_alive) * 8.0
