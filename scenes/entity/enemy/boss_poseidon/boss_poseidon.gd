extends KinematicActor

const ENDING_SCENE := preload("res://scenes/game_state/gst_game_end.tscn")

const ENDING_DELAY := 3.0

enum States {
	IDLE,
	DASH,
	MAD_BULLET
}

export (float) var idle_duration := 2.0
export (float) var dash_duration := 0.5

export (int) var max_dash_combo_before_mad_bullet_lol = 4
export (float) var mad_bullet_rate := 1.5
export (int) var max_mad_bullets := 5

export (float) var attack_cooldown := 0.5
export (float) var dash_speed = 320.0
export (float, 0.0, 1.0) var wheelchair_steering := 0.94

var previous_state : int = States.IDLE
var current_state : int = States.IDLE

var direction_to_player : Vector2 = Vector2.ZERO

onready var anim_sprite : AnimatedSprite = $Sprite
onready var anim : AnimationPlayer = $AnimationPlayer
onready var emitter_mad := $MadBullets

var state_elapsed := 0.0
var dash_combo := 0
var mad_bullet_counter := 0

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
			anim_sprite.scale.x = -1.0
		elif h_dir == -1:
			facing_name = "left"
			anim_sprite.scale.x = 1.0
			
	return facing_name
	
func _animate_walk():
	var anim_name := ""
	
	var suffix = "_" + get_dominant_facing()
	
	if suffix in ["_left", "_right"]:
		suffix = "_h"
	
	anim_name = "move" + suffix
	
	var prev_anim_frame = anim_sprite.frame
	
	anim_sprite.play(anim_name)
	anim_sprite.frame = prev_anim_frame
	
func is_visible_in_canvas() -> bool:
	var vic := true
	
	var screen_pos := get_global_transform_with_canvas().origin
	var padding := Vector2(32.0, 32.0)
	
	if screen_pos.x > 320.0 + padding.x || screen_pos.x < 0.0 - padding.x || screen_pos.y > 240.0 + padding.y || screen_pos.y < 0.0 - padding.y:
		vic = false
	
	return vic
	
func _explode():
	var explosion = EXPLOSION_EFFECT.instance()
	
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
func _on_damage_taken(damage_amount : int, source : Node):
	anim.stop()
	anim.play("TakeDamage")
	
func _on_death(damage_amount : int, source : Node):
	dead = true
	
	_explode()
	
	anim_sprite.animation = "die"
	
	var ending_timer := get_tree().create_timer(ENDING_DELAY)
	
	yield(ending_timer, "timeout")
	
	Global.change_scene(ENDING_SCENE)

func set_state(new_state_id : int):
	_on_state_exit(current_state)
	
	state_elapsed = 0.0
	anim_sprite.flip_h = false
	anim_sprite.scale.x = 1.0
	
	previous_state = current_state
	current_state = new_state_id
	
	_on_state_enter(current_state)
	
func _on_state_exit(state : int):
	match state:
		States.MAD_BULLET:
			dash_combo = 0
	
func _on_state_enter(state : int):
	match state:
		States.IDLE:
			attacking = false
			mad_bullet_counter = 0
		States.DASH:
			$RamSound.play()
			anim.play("TurboShake")
			
			attacking = false
			
			direction_to_player = get_direction_to_player()
			
			if dash_combo >= max_dash_combo_before_mad_bullet_lol:
				set_state(States.MAD_BULLET)
		States.MAD_BULLET:
			fire_mad_bullets()
	
func fire_mad_bullets():
	if dead:
		return
		
	if Global.player.dead:
		return
	
	if mad_bullet_counter >= max_mad_bullets:
		set_state(States.IDLE)
		return
	
	emitter_mad.fire()
	mad_bullet_counter += 1
	
	yield(get_tree().create_timer(mad_bullet_rate), "timeout")
	
	fire_mad_bullets()
	
func get_direction_to_player() -> Vector2:
	var dir := Vector2.RIGHT
	
	if is_instance_valid(Global.player):
		var angle_to_player := global_position.angle_to_point(Global.player.global_position)
		
		dir = Vector2.LEFT.rotated(angle_to_player)
	
	return dir
	
func _physics_process(delta):
	if dead:
		return
	
	if Global.player.dead:
		set_state(States.IDLE)
		return
	
	look_angle = velocity.normalized()
	
	state_elapsed += delta
	
	if not is_visible_in_canvas():
		set_state(States.IDLE)
	
	match current_state:
		States.IDLE:
			_animate_walk()
			
			velocity *= wheelchair_steering
			
			if state_elapsed >= idle_duration:
				set_state(States.DASH)
		States.DASH:
			if attacking:
				anim_sprite.animation = "speen"
				
				anim_sprite.flip_h = anim_sprite.frame == 3
			else:
				_animate_walk()
			
			if Global.player.dead:
				set_state(States.IDLE)
				
			velocity = velocity.linear_interpolate(direction_to_player * dash_speed, 1.0 - steering)
			
			if can_attack(Global.player) && not attacking:
				attacking = attack(Global.player)
				
				if attacking:
					dash_combo += 1
			
			if state_elapsed >= dash_duration:
				set_state(States.IDLE)
		States.MAD_BULLET:
			anim_sprite.flip_h = false
			anim_sprite.animation = "use_trident"
