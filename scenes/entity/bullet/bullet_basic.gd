extends Node2D
class_name Bullet

var velocity := Vector2.ZERO

export (int) var damage := 1
export (float) var base_speed := 128.0
export (float) var life_time := 10.0

onready var hitbox : ShapeCast2D = $Hitbox

var elapsed_alive := 0.0

func is_visible_in_canvas() -> bool:
	var vic := true
	
	var screen_pos := get_global_transform_with_canvas().origin
	var padding := Vector2(32.0, 32.0)
	
	if screen_pos.x > 320.0 + padding.x || screen_pos.x < 0.0 - padding.x || screen_pos.y > 240.0 + padding.y || screen_pos.y < 0.0 - padding.y:
		vic = false
	
	return vic
	
func _get_shape_query_from_shape_cast_2d(shape_cast : ShapeCast2D) -> Physics2DShapeQueryParameters:
	var shape := Physics2DShapeQueryParameters.new()
	
	shape.collide_with_areas = shape_cast.collide_with_areas
	shape.collide_with_bodies = shape_cast.collide_with_bodies
	shape.collision_layer = shape_cast.collision_mask
	shape.exclude = [self]
	shape.margin = shape_cast.margin
	shape.motion = shape_cast.target_position
	shape.transform = shape_cast.global_transform
	shape.shape_rid = shape_cast.shape.get_rid()
	
	return shape
	
func _scan_for_actors(shape_cast : ShapeCast2D) -> PoolIntArray:
	var space_state := get_world_2d().direct_space_state
	
	var hit_test_shape := _get_shape_query_from_shape_cast_2d(shape_cast)
	
	var hit_test_results := space_state.intersect_shape(hit_test_shape, shape_cast.max_results)
	
	var actors : PoolIntArray = []
	
	for i in range(hit_test_results.size()):
		var result : Dictionary = hit_test_results[i]
		var instance_id : int = result.collider.get_instance_id()
		
		if not actors.has(instance_id):
			actors.append(instance_id)
	
	return actors
	
func check_collision():
	var actor_ids := _scan_for_actors(hitbox)
	
	for i in range(actor_ids.size()):
		var instance = instance_from_id(actor_ids[i])
		
		if instance is KinematicActor:
			if instance.dead:
				continue
			
			instance.take_damage(self, damage)
			queue_free()
	
func _process(delta):
	if not is_visible_in_canvas():
		queue_free()
		return
	
	elapsed_alive += delta
	
	if elapsed_alive >= life_time:
		queue_free()
	
	z_index = int(max(get_global_transform_with_canvas().origin.y, 0))
	
func _physics_process(delta):
	check_collision()
	
	position += velocity * delta
