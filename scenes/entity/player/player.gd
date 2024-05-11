extends KinematicActor

export (float, 0.0, 0.99) var walk_steering := 0.1
export (float, 0.0, 0.99) var swim_steering := 0.96

export (float) var walk_speed = 96.0
export (float) var swim_speed = 280.0

enum PlayerStates {
	IDLE,
	WALK,
	SWIM
}

var current_state : int = PlayerStates.IDLE
var input_direction : Vector2 = Vector2.ZERO

func _process(delta : float):
	$StateText.text = PlayerStates.keys()[current_state]
	
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	match current_state:
		PlayerStates.IDLE:
			_tick_idle_state(delta)
		PlayerStates.WALK:
			_tick_walk_state(delta)
		PlayerStates.SWIM:
			_tick_swim_state(delta)
	
func is_input_moving() -> bool:
	return input_direction != Vector2.ZERO
	
func _tick_idle_state(delta : float):
	if is_input_moving():
		current_state = PlayerStates.WALK
	
func _tick_walk_state(delta : float):
	base_speed = walk_speed
	steering = walk_steering
	
	direction = input_direction
	
	if Input.is_action_pressed("run"):
		current_state = PlayerStates.SWIM
	
	if not is_input_moving():
		current_state = PlayerStates.IDLE
	
func _tick_swim_state(delta : float):
	base_speed = swim_speed
	steering = swim_steering
	
	direction = input_direction
	
	if not Input.is_action_pressed("run"):
		current_state = PlayerStates.WALK
		
	if not is_input_moving():
		current_state = PlayerStates.IDLE
