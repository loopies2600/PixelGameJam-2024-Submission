extends KinematicActor
class_name PlayerActor

const INTERACTION_OFFSET := Vector2(32, 0)
const CAMERA_OFFSET := Vector2(0, -14)
const LERP_WEIGHT := 8.0

const HURT_FREEZE_TIME := 0.25
const GRACE_TIME := 1.0

const ATTACK_1_DATA : AttackStateData = preload("res://data/player/attack1_state_data.tres")

export (float, 0.0, 0.99) var walk_steering := 0.3
export (float, 0.0, 0.99) var swim_steering := 0.96

export (float) var walk_speed := 86.0
export (float) var swim_speed := 280.0
export (float) var swing_dash := 300.0

export (int, FLAGS, "Double Speed", "Loot Luck", "Double Strength", "FEVER???") var perks := 0

export (Color) var trail_color := Color.cadetblue

export (float) var hurt_cam_shake := 3.0
export (float) var death_cam_shake := 5.0

enum PlayerStates {
	IDLE,
	WALK,
	DIVE,
	ATTACK,
	HURT,
	DEAD,
	CUTSCENE # siempre al final
}

var current_state : int = PlayerStates.IDLE
var previous_state : int = PlayerStates.IDLE

var input_direction : Vector2 = Vector2.ZERO
var can_input := true
var lock_anim := false

var current_combo : int = 1

onready var cam : Camera2D = $Camera2D
onready var interaction_ray : RayCast2D = $InteractionRay
onready var anim_sprite : AnimatedSprite = $MainSprite
onready var attack_area : ShapeCast2D = $AttackHitPivot/AttackHitTester
onready var inventory : Inventory = $PlayerInventory
onready var punch_sound : AudioStreamPlayer = $SuccessfulPunchSound
onready var attack_pivot : Node2D = $AttackHitPivot
onready var swing_sound : AudioStreamPlayer = $SwordSwingSound
onready var extra_anim : AnimationPlayer = $SpriteAnims
onready var pickup_sound : AudioStreamPlayer = $PickupSound

onready var _bwalk := walk_speed
onready var _bswim := swim_speed
onready var _bdash := swing_dash

var current_sprite : Texture = null

func _ready():
	Global.player = self
	Global.focusActor = self
	
	CutsceneManager.connect("cutscene_started", self, "_on_cutscene_start")
	CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
	
	anim_sprite.connect("frame_changed", self, "_on_anim_frame_update")
	
	inventory.connect("item_added", self, "_on_item_added")
	
	$DiveTrailTimer.connect("timeout", self, "_spawn_dive_trail")
	
func _on_item_added(item_id : int):
	pickup_sound.play()
	
func _spawn_dive_trail():
	var diving : bool = current_state == PlayerStates.DIVE
	var attacking : bool = current_state == PlayerStates.ATTACK
	
	var valid := attacking or diving
	
	if not valid:
		return
	
	var ghost_spr := GHOST_SPRITE.instance()
	
	ghost_spr.texture = current_sprite
	ghost_spr.global_transform = global_transform
	ghost_spr.scale = anim_sprite.scale
	ghost_spr.base_z_index = -1
	ghost_spr.modulate = trail_color
	
	add_child(ghost_spr)
	ghost_spr.set_as_toplevel(true)
	
func _on_anim_frame_update():
	if anim_sprite.animation.begins_with("attack"):
		_check_attack_hit()
	
func _on_cutscene_start():
	can_input = false
	
	set_state(PlayerStates.CUTSCENE)
	
func _on_cutscene_end():
	can_input = true
	
	set_state(PlayerStates.IDLE)
	
func _on_damage_taken(damage_amount, source):
	var lethal := health <= 0
	
	_play_punch_sound(lethal)
	
	set_state(PlayerStates.HURT)
	
func _on_death(damage_amount, source):
	set_state(PlayerStates.DEAD)
	
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
	
	var state_name : String = PlayerStates.keys()[current_state]
	
	if current_state == PlayerStates.ATTACK:
		state_name += str(current_combo)
	
	var suffix = "_" + get_dominant_facing()
	
	if suffix in ["_left", "_right"]:
		suffix = "_h"
	
	anim_name = state_name.to_lower() + suffix
	
	var prev_anim_frame = anim_sprite.frame
	
	anim_sprite.play(anim_name)
	anim_sprite.frame = prev_anim_frame
	
	current_sprite = anim_sprite.frames.get_frame(anim_sprite.animation, anim_sprite.frame)
	
func _on_state_exit(state : int):
	match state:
		PlayerStates.ATTACK:
			can_input = true
			anim_sprite.offset = Vector2.ZERO
		PlayerStates.HURT:
			var grace_timer := get_tree().create_timer(GRACE_TIME)
			
			invencible = true
			
			yield(grace_timer, "timeout")
			
			invencible = false
			
func _on_successful_punch(target : KinematicActor):
	._on_successful_punch(target)
	
	var lethal := target.health <= 0
	
	if lethal:
		cam.shake(death_cam_shake * 0.75)
	else:
		cam.shake(hurt_cam_shake / 2.0)
	
	_play_punch_sound(lethal)
	
func _play_punch_sound(lethal : bool):
	punch_sound.stop()
	
	punch_sound.pitch_scale = rand_range(0.75, 1.75)
	
	if lethal:
		punch_sound.pitch_scale = rand_range(0.4, 0.6)
		
	punch_sound.play()
	
func _on_state_enter(state : int):
	anim_sprite.frame = 0
	
	match state:
		PlayerStates.IDLE:
			if previous_state != PlayerStates.ATTACK:
				lock_anim = true
				
				var idle_anim_delay := get_tree().create_timer(0.1)
				
				yield(idle_anim_delay, "timeout")
				
				lock_anim = false
		PlayerStates.ATTACK:
			swing_sound.pitch_scale = rand_range(1.0, 1.3)
			swing_sound.play()
			
			velocity = Vector2.ZERO
			steering = 0.782
			look_angle = look_at_cursor()
			_reposition_sprite()
			
			can_input = false
			
			yield(anim_sprite, "animation_finished")
			
			set_state(PlayerStates.IDLE)
		PlayerStates.HURT:
			cam.shake(hurt_cam_shake)
			extra_anim.play("Hurt")
			frozen = true
			
			var freeze_timer := get_tree().create_timer(HURT_FREEZE_TIME)
				
			yield(freeze_timer, "timeout")
			
			frozen = false
			
			set_state(PlayerStates.IDLE)
		PlayerStates.DEAD:
			cam.shake(death_cam_shake)
			_play_punch_sound(true)
			
			yield(get_tree(), "idle_frame")
			yield(get_tree(), "idle_frame")
			
			set_process(false)
			set_physics_process(false)
			set_process_input(false)
			
			visible = true
			anim_sprite.animation = "dead_h"
		_:
			_reposition_sprite()
	
func set_state(new_state_id : int):
	_on_state_exit(current_state)
	
	previous_state = current_state
	current_state = new_state_id
	
	_on_state_enter(current_state)
	
func reset_combo_counter():
	current_combo = 1
	
func _physics_process(delta):
	velocity = get_walk_velocity()
	
func _process(delta : float):
	_check_perks()
	
	attack_pivot.rotation = look_angle.angle()
	interaction_ray.cast_to = INTERACTION_OFFSET.rotated(look_angle.angle())
	
	if can_input:
		check_input()
	
	match current_state:
		PlayerStates.IDLE:
			_tick_idle_state(delta)
		PlayerStates.WALK:
			_tick_walk_state(delta)
		PlayerStates.DIVE:
			_tick_diving_state(delta)
		PlayerStates.ATTACK:
			_tick_attack_state(delta)
		PlayerStates.CUTSCENE:
			_tick_cutscene_state(delta)
		PlayerStates.DEAD:
			_tick_dead_state(delta)
			
	_animate()
	
func _check_perks():
	walk_speed = _bwalk
	swim_speed = _bswim
	swing_dash = _bdash
	
	if BitwiseUtil.isBitEnabled(perks, 1):
		walk_speed = _bwalk * 2.0
		swim_speed = _bswim * 2.0
		swing_dash = _bdash * 2.0
		
		var ghost_sprite = GHOST_SPRITE.instance()
		
		ghost_sprite.base_z_index = -1
		
		get_parent().add_child(ghost_sprite)
		
		ghost_sprite.global_transform = anim_sprite.global_transform
		
		ghost_sprite.texture = current_sprite
		
func look_at_cursor() -> Vector2:
	var angle_to_cursor := get_global_mouse_position().angle_to_point(global_position)
	
	return Vector2.RIGHT.rotated(angle_to_cursor)
	
func check_input():
	input_direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	if is_input_moving():
		look_angle = input_direction
	
	if Input.is_action_just_pressed("interact"):
		_try_interaction()
	
	if Input.is_action_just_pressed("attack"):
		set_state(PlayerStates.ATTACK)
	
func try_attack():
	var actor_ids := _scan_for_actors(attack_area)
	
	for i in range(actor_ids.size()):
		var target = instance_from_id(actor_ids[i])
		
		if target is KinematicActor:
			attack(target)
			
	attacking = true
	
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
		set_state(PlayerStates.DIVE)
	
	if not is_input_moving():
		set_state(PlayerStates.IDLE)
	
func _tick_diving_state(delta : float):
	base_speed = lerp(base_speed, swim_speed, LERP_WEIGHT * delta)
	steering = lerp(steering, swim_steering, (LERP_WEIGHT * 2.0) * delta)
	
	direction = input_direction
	
	if not Input.is_action_pressed("run"):
		set_state(PlayerStates.WALK)
		
	if not is_input_moving():
		set_state(PlayerStates.IDLE)
	
func _tick_attack_state(delta : float):
	base_speed = 0.0
	
	can_input = false
	
	if ATTACK_1_DATA.can_attack_in_frame[anim_sprite.frame] == true:
		attacking = false
		
		if Input.is_action_just_pressed("attack"):
			set_state(PlayerStates.ATTACK)
		
func _check_attack_hit():
	attacking = false
	
	var frame_idx : int = anim_sprite.frame
	var atk_data : AttackStateData = get("ATTACK_%s_DATA" % current_combo)
	
	if atk_data.scan_in_frame[frame_idx] == true:
		try_attack()
	
	velocity = (swing_dash * atk_data.frame_impulse[frame_idx]) * look_at_cursor()
	_reposition_sprite()
	
func _reposition_sprite():
	if current_state != PlayerStates.ATTACK: 
		anim_sprite.offset = Vector2.ZERO
		return
	
	var frame_idx : int = anim_sprite.frame
	var atk_data : AttackStateData = get("ATTACK_%s_DATA" % current_combo)
	
	anim_sprite.offset = atk_data.frame_offset[frame_idx]
	
func _tick_cutscene_state(delta : float):
	velocity = Vector2.ZERO
	direction = Vector2.ZERO
	input_direction = Vector2.ZERO
	#look_angle = Vector2.ZERO
	
	can_input = false
	
func _tick_dead_state(delta : float):
	_tick_cutscene_state(delta)
