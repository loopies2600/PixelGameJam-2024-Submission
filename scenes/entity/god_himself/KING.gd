extends KinematicActor
class_name KingActor

const TROLL_DELAY := 0.25

var fish_count := 0

enum States {
	WALK,
	CHASE,
	ATTACK
}

var previous_state : int = States.WALK
var current_state : int = States.CHASE

var lock_anim : bool = false
var active : bool = false

var wander_direction : Vector2 = Vector2.RIGHT

onready var wander_timer : Timer = $WanderTimer
onready var anim_sprite : AnimatedSprite = $AnimatedSprite

func _ready():
	wander_timer.connect("timeout", self, "_on_wander_timer_timeout")
	
	_refresh_wander_direction()
	
func get_dominant_facing() -> String:
	var h_dir = sign(look_angle.dot(Vector2.RIGHT))
	var v_dir = sign(look_angle.dot(Vector2.UP))
	
	var h_dot := abs(look_angle.dot(Vector2.RIGHT))
	
	var facing_name := "right"
	
	if v_dir == 1:
		facing_name = "up"
	elif v_dir == -1:
		facing_name = "down"
	
	if h_dot > 0.7:
		if h_dir == 1:
			facing_name = "right"
			anim_sprite.scale.x = 1.0
		elif h_dir == -1:
			facing_name = "left"
			anim_sprite.scale.x = -1.0
			
	return facing_name
	
func _animate():
	if lock_anim:
		return
	
	var anim_name := ""
	
	var state_name : String = States.keys()[current_state]
	
	var suffix = "_" + get_dominant_facing()
	
	if suffix in ["_left", "_right"]:
		suffix = "_h"
	
	anim_name = state_name.to_lower() + suffix
	
	var prev_anim_frame = anim_sprite.frame
	
	anim_sprite.play(anim_name)
	anim_sprite.frame = prev_anim_frame
	
func _on_wander_timer_timeout():
	wander_timer.wait_time = rand_range(4.0, 8.0)
	
	_refresh_wander_direction()
	
func _refresh_wander_direction():
	randomize()
	
	var prev_dir := wander_direction
	
	while abs(wander_direction.dot(prev_dir)) > 0.3:
		var random_angle := rand_range(0.0, TAU)
		
		wander_direction = Vector2.RIGHT.rotated(random_angle)
	
func _on_damage_taken(damage_amount : int, source):
	health = max_health
	
	if source is PlayerActor:
		source.take_damage(self, damage_amount)
	
	yield(get_tree().create_timer(TROLL_DELAY), "timeout")
	
	set_state(States.ATTACK)
	
func set_state(new_state_id : int):
	_on_state_exit(current_state)
	
	previous_state = current_state
	current_state = new_state_id
	
	_on_state_enter(current_state)
	
func _on_state_exit(state_id : int):
	pass
	
func _on_state_enter(state_id : int):
	match state_id:
		States.ATTACK:
			velocity = Vector2.ZERO
			
			Global.player.set_state(PlayerActor.PlayerStates.DEAD)
			attack(Global.player)
	
func _process(delta):
	_animate()
	
func _physics_process(delta):
	match current_state:
		States.WALK:
			var motion := wander_direction * base_speed
			
			motion *= wander_timer.time_left / wander_timer.wait_time
			velocity = velocity.linear_interpolate(motion, 1.0 - steering)
			
		States.CHASE:
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos : Vector2 = Global.player.global_position
			
			var angle_to_player := global_position.angle_to_point(target_pos)
			
			if distance_to_player < pow(attack_distance, 2.0):
				var close_to_left := false
				
				var left_side := target_pos + Vector2(-32.0, 0.0)
				var right_side := target_pos + Vector2(32.0, 0.0)
				
				var angle_to_left_side := global_position.angle_to_point(left_side)
				var angle_to_right_side := global_position.angle_to_point(right_side)
				
				var preferred_angle := angle_to_right_side
				var preferred_side := right_side
				
				close_to_left = global_position.distance_squared_to(left_side) < global_position.distance_squared_to(right_side)
				
				if close_to_left:
					preferred_angle = angle_to_left_side
					preferred_side = left_side
				
				if abs(global_position.y - preferred_side.y) < 8.0:
					velocity *= 0.9
					
					if velocity.length() < 8.0:
						set_state(States.ATTACK)
				else:
					velocity = Vector2.LEFT.rotated(preferred_angle) * base_speed
			else:
				velocity = Vector2.LEFT.rotated(angle_to_player) * base_speed
			
	look_angle = velocity.normalized()
