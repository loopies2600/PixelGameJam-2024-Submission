extends KinematicActor
class_name PlayerActor

const INTERACTION_OFFSET := Vector2(32, 0)
const CAMERA_OFFSET := Vector2(0, -14)
const LERP_WEIGHT := 8.0

const ATTACK_1_ANIM_OFFSET := Vector2(10, -10)
const ATTACK_1_HURT_FRAMES := [false, false, false, true, false, false]

export (float, 0.0, 0.99) var walk_steering := 0.3
export (float, 0.0, 0.99) var swim_steering := 0.96

export (float) var walk_speed = 86.0
export (float) var swim_speed = 280.0

enum PlayerStates {
	IDLE,
	WALK,
	SWIM,
	ATTACK
	CUTSCENE # siempre al final
}

var current_state : int = PlayerStates.IDLE
var input_direction : Vector2 = Vector2.ZERO
var can_input := true

var look_angle : Vector2 = Vector2.ZERO

var current_combo : int = 1

onready var cam : Camera2D = $Camera2D
onready var interaction_ray : RayCast2D = $InteractionRay
onready var anim_sprite : AnimatedSprite = $MainSprite

func _ready():
	Global.player = self
	Global.focusActor = self
	
	CutsceneManager.connect("cutscene_started", self, "_on_cutscene_start")
	CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
	
	anim_sprite.connect("frame_changed", self, "_on_anim_frame_update")
	
func _on_anim_frame_update():
	if anim_sprite.animation.begins_with("attack"):
		_check_attack_hit()
	
func _on_cutscene_start():
	can_input = false
	
	set_state(PlayerStates.CUTSCENE)
	
func _on_cutscene_end():
	can_input = true
	
	set_state(PlayerStates.IDLE)
	
func _on_death(damage_amount, source):
	visible = false
	
func _build_state_anim_name() -> String:
	var anim_name := ""
	
	var state_name : String = PlayerStates.keys()[current_state]
	
	if current_state == PlayerStates.ATTACK:
		state_name += str(current_combo)
		
	var suffix := "_h"
	
	if not is_equal_approx(look_angle.x, 0.0):
		suffix = "_h"
		anim_sprite.scale.x = -1.0 if sign(look_angle.x) == -1 else 1.0
	
	match int(sign(round(look_angle.y))):
		-1:
			suffix = "_up"
			anim_sprite.scale.x = 1.0
		1:
			suffix = "_down"
			anim_sprite.scale.x = 1.0
	
	anim_name = state_name.to_lower() + suffix
	
	return anim_name
	
func _on_state_exit(state : int):
	match state:
		PlayerStates.ATTACK:
			can_input = true
			anim_sprite.offset = Vector2.ZERO
	
func _on_state_enter(state : int):
	match state:
		PlayerStates.ATTACK:
			if current_combo == 1:
				anim_sprite.offset = ATTACK_1_ANIM_OFFSET
			
			can_input = false
			
			yield(anim_sprite, "animation_finished")
			
			set_state(PlayerStates.IDLE)
	
func set_state(new_state_id : int):
	_on_state_exit(current_state)
	current_state = new_state_id
	_on_state_enter(current_state)
	
func reset_combo_counter():
	current_combo = 1
	
func _process(delta : float):
	interaction_ray.cast_to = INTERACTION_OFFSET.rotated(look_angle.angle())
	
	if can_input:
		check_input()
	
	match current_state:
		PlayerStates.IDLE:
			_tick_idle_state(delta)
		PlayerStates.WALK:
			_tick_walk_state(delta)
		PlayerStates.SWIM:
			_tick_swim_state(delta)
		PlayerStates.ATTACK:
			_tick_attack_state(delta)
		PlayerStates.CUTSCENE:
			_tick_cutscene_state(delta)
	
	anim_sprite.animation = _build_state_anim_name()
	
func check_input():
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_input_moving():
		look_angle = input_direction
	
	if Input.is_action_just_pressed("interact"):
		_try_interaction()
	
	if Input.is_action_just_pressed("attack"):
		set_state(PlayerStates.ATTACK)
	
func try_attack():
	var _shapecast : ShapeCast2D = $AttackAreaTest
	
	if not _shapecast.is_colliding(): return
	
	for i in range(_shapecast.get_collision_count()):
		var collider = _shapecast.get_collider(i)
		
		if collider is KinematicActor:
			attack(collider)
			
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
		set_state(PlayerStates.WALK)
	
func _tick_walk_state(delta : float):
	base_speed = lerp(base_speed, walk_speed, LERP_WEIGHT * delta)
	steering = lerp(steering, walk_steering, LERP_WEIGHT * delta)
	
	direction = input_direction
	
	if Input.is_action_pressed("run"):
		set_state(PlayerStates.SWIM)
	
	if not is_input_moving():
		set_state(PlayerStates.IDLE)
	
func _tick_swim_state(delta : float):
	base_speed = lerp(base_speed, swim_speed, LERP_WEIGHT * delta)
	steering = lerp(steering, swim_steering, (LERP_WEIGHT * 2.0) * delta)
	
	direction = input_direction
	
	if not Input.is_action_pressed("run"):
		set_state(PlayerStates.WALK)
		
	if not is_input_moving():
		set_state(PlayerStates.IDLE)
	
func _tick_attack_state(delta : float):
	base_speed = lerp(base_speed, 0.0, LERP_WEIGHT * delta)
	
func _check_attack_hit():
	attacking = false
	
	if ATTACK_1_HURT_FRAMES[anim_sprite.frame] == true:
		try_attack()
	
func _tick_cutscene_state(delta : float):
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	input_direction = Vector2.ZERO
	#look_angle = Vector2.ZERO
	
	can_input = false
