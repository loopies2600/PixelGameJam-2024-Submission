extends KinematicActor

export (float, 0.0, 360.0) var base_angle := 0
export (Vector2) var wall_scan_ray_length := Vector2(32.0, 0.0)

enum States {
	BACK_AND_FORTH,
	INFLATE
}

var current_state : int = States.BACK_AND_FORTH

var dir : int = 1

onready var anim_sprite : AnimatedSprite = $Flipdude/AnimatedSprite
onready var danger_area : ShapeCast2D = $DangerCast
onready var extra_anim : AnimationPlayer = $AnimationPlayer

func _process(delta):
	look_angle = velocity.normalized()
	
func _find_wall() -> bool:
	var space_state := get_world_2d().direct_space_state
	
	var towards_position := wall_scan_ray_length.rotated(velocity.angle())
	
	var result := space_state.intersect_ray(global_position, global_position + towards_position, [self], collision_mask)
	
	return !result.empty()
	
func try_attack():
	if attacking: return
	
	var actor_ids := _scan_for_actors(danger_area)
	
	for i in range(actor_ids.size()):
		var target = instance_from_id(actor_ids[i])
		
		if target is KinematicActor:
			attack(target)
			
	attacking = true
	
func _physics_process(delta):
	match current_state:
		States.BACK_AND_FORTH:
			attacking = false
			
			anim_sprite.animation = "idle"
			
			velocity = (Vector2.RIGHT.rotated(deg2rad(base_angle)) * base_speed) * dir
			
			if _scan_for_actors(danger_area) && Global.player.dead == false:
				current_state = States.INFLATE
			
			if _find_wall():
				dir = -dir
		States.INFLATE:
			if Global.player.dead:
				current_state = States.BACK_AND_FORTH
			
			if extra_anim.current_animation != "Inflate":
				extra_anim.play("Inflate")
			
			try_attack()
			
			velocity *= 0.9
			
			anim_sprite.animation = "inflate"
			
			yield(extra_anim, "animation_finished")
			
			current_state = States.BACK_AND_FORTH
	
	rotation = velocity.angle()
	anim_sprite.flip_v = rotation >= 0.0
