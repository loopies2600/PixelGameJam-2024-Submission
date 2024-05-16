extends KinematicActor

export (float, 0.0, 360.0) var base_angle := 0
export (Vector2) var wall_scan_ray_length := Vector2(32.0, 0.0)

enum States {
	BACK_AND_FORTH,
	INFLATE
}

var current_state : int = States.BACK_AND_FORTH

var dir : int = 1

func _process(delta):
	look_angle = velocity.normalized()
	
func _find_wall() -> bool:
	var space_state := get_world_2d().direct_space_state
	
	var towards_position := wall_scan_ray_length.rotated(velocity.angle())
	
	var result := space_state.intersect_ray(global_position, global_position + towards_position, [self], collision_mask)
	
	return !result.empty()
	
func _physics_process(delta):
	match current_state:
		States.BACK_AND_FORTH:
			velocity = (Vector2.RIGHT.rotated(deg2rad(base_angle)) * base_speed) * dir
			
			if _find_wall():
				dir = -dir
