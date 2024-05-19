extends KinematicActor
class_name SwordfishActor

const TROLL_DELAY := 0.25

export (float) var attack_chase_wait := 2.0
export (int) var attack_hit_frame := 2
export (Vector2) var sprite_offset := Vector2(8, 0)

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
	anim_sprite.connect("frame_changed", self, "_on_anim_frame_changed")
	
	wander_timer.connect("timeout", self, "_on_wander_timer_timeout")
	
	_refresh_wander_direction()
	
	yield(owner, "ready")
	
func _on_anim_frame_changed():
	if anim_sprite.animation == "attack":
		if anim_sprite.frame == 0 && attacking:
			current_state = States.WALK
			attacking = false
			
			var wait_to_attack := get_tree().create_timer(attack_chase_wait)
			
			yield(wait_to_attack, "timeout")
			
			current_state = States.CHASE
			
		if current_state == States.ATTACK:
			if anim_sprite.frame == attack_hit_frame:
				attacking = attack(Global.player)
	
func _animate():
	anim_sprite.playing = not lock_anim
	
	if lock_anim:
		return
	
	var anim_name := ""
	
	var state_name : String = States.keys()[current_state]
	
	anim_name = state_name.to_lower()
	
	var flip_h : bool = true
	
	if is_instance_valid(Global.player):
		flip_h = true if Global.player.global_position.x > global_position.x else false
	
	anim_sprite.offset = sprite_offset if flip_h else -sprite_offset
	anim_sprite.flip_h = flip_h
	
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
	
func _process(delta):
	_animate()
	
func _physics_process(delta):
	var chase_direction := Vector2.LEFT
	
	if is_instance_valid(Global.player):
		chase_direction = Vector2.RIGHT if Global.player.anim_sprite.animation.begins_with("attack") else Vector2.LEFT
	
	match current_state:
		States.WALK:
			var motion := wander_direction * base_speed
			
			motion *= wander_timer.time_left / wander_timer.wait_time
			velocity = velocity.linear_interpolate(motion, 1.0 - steering)
			
			if find_player():
				current_state = States.CHASE
		States.CHASE:
			if not find_player():
				current_state = States.WALK
				
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos := Vector2.ZERO
			
			if is_instance_valid(Global.player):
				target_pos = Global.player.global_position
			
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
				
				if abs(global_position.y - preferred_side.y) < 16.0:
					velocity *= 0.9
					
					set_state(States.ATTACK)
				else:
					velocity = chase_direction.rotated(preferred_angle) * base_speed
			else:
				velocity = chase_direction.rotated(angle_to_player) * base_speed
			
	look_angle = velocity.normalized()
