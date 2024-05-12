extends KinematicActor
class_name PlayerActor

const INTERACTION_OFFSET := Vector2(32, 0)
const CAMERA_OFFSET := Vector2(0, -14)
const LERP_WEIGHT := 8.0

export (float, 0.0, 0.99) var walk_steering := 0.1
export (float, 0.0, 0.99) var swim_steering := 0.96

export (float) var walk_speed = 96.0
export (float) var swim_speed = 280.0

enum PlayerStates {
	IDLE,
	WALK,
	SWIM,
	CUTSCENE # siempre al final
}

var current_state : int = PlayerStates.IDLE
var input_direction : Vector2 = Vector2.ZERO
var can_input := true

var look_angle : Vector2 = Vector2.ZERO

onready var cam : Camera2D = $Camera2D
onready var interaction_ray : RayCast2D = $InteractionRay

func _ready():
	Global.player = self
	Global.focusActor = self
	
	CutsceneManager.connect("cutscene_started", self, "_on_cutscene_start")
	CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
	
func _on_cutscene_start():
	can_input = false
	
	current_state = PlayerStates.CUTSCENE
	
func _on_cutscene_end():
	can_input = true
	
	current_state = PlayerStates.IDLE
	
func _on_death(damage_amount, source):
	visible = false
	print("test")
	
func _process(delta : float):
	interaction_ray.cast_to = INTERACTION_OFFSET.rotated(look_angle.angle())
	$StateText.text = PlayerStates.keys()[current_state]
	
	if can_input:
		check_input()
	
	match current_state:
		PlayerStates.IDLE:
			_tick_idle_state(delta)
		PlayerStates.WALK:
			_tick_walk_state(delta)
		PlayerStates.SWIM:
			_tick_swim_state(delta)
		PlayerStates.CUTSCENE:
			_tick_cutscene_state(delta)
	
func check_input():
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_input_moving():
		look_angle = input_direction
	
	if Input.is_action_just_pressed("interact"):
		_try_interaction()
	
	if Input.is_action_just_pressed("attack"):
		try_attack()
	
func try_attack():
	var _shapecast : ShapeCast2D = $AttackAreaTest
	
	if not _shapecast.is_colliding(): return
		
	for i in range(_shapecast.get_collision_count()):
		var collider = _shapecast.get_collider(i)
		
		if collider is KinematicActor:
			collider.take_damage(self, strength)
			
func _try_interaction():
	if current_state == PlayerStates.CUTSCENE:
		return
	
	var interactable : Interactable = _check_interaction_ray()
	
	if interactable:
		interactable.interact()
		
func _check_interaction_ray() -> Interactable:
	var hit : Interactable = null
	
	if interaction_ray.is_colliding():
		var collider := interaction_ray.get_collider()
		
		if collider is Interactable:
			hit = collider
	
	return hit
	
func is_input_moving() -> bool:
	return input_direction != Vector2.ZERO
	
func _tick_idle_state(delta : float):
	base_speed = lerp(base_speed, 0.0, LERP_WEIGHT * delta)
	
	if is_input_moving():
		current_state = PlayerStates.WALK
	
func _tick_walk_state(delta : float):
	base_speed = lerp(base_speed, walk_speed, LERP_WEIGHT * delta)
	steering = lerp(steering, walk_steering, LERP_WEIGHT * delta)
	
	direction = input_direction
	
	if Input.is_action_pressed("run"):
		current_state = PlayerStates.SWIM
	
	if not is_input_moving():
		current_state = PlayerStates.IDLE
	
func _tick_swim_state(delta : float):
	base_speed = lerp(base_speed, swim_speed, LERP_WEIGHT * delta)
	steering = lerp(steering, swim_steering, (LERP_WEIGHT * 2.0) * delta)
	
	direction = input_direction
	
	if not Input.is_action_pressed("run"):
		current_state = PlayerStates.WALK
		
	if not is_input_moving():
		current_state = PlayerStates.IDLE
	
func _tick_cutscene_state(delta : float):
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	input_direction = Vector2.ZERO
	#look_angle = Vector2.ZERO
	
	can_input = false
