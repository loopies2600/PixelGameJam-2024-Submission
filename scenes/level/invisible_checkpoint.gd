extends CollisionShape2D

export (int, LAYERS_2D_PHYSICS) var collision_mask := 1

var query := Physics2DShapeQueryParameters.new()

func _ready():
	query.transform = global_transform
	query.shape_rid = shape.get_rid()
	query.collide_with_bodies = true
	query.collision_layer = collision_mask
	
func _physics_process(delta):
	var space_state := get_world_2d().direct_space_state
	
	var hit_test_results := space_state.intersect_shape(query, 32)
	
	if not hit_test_results.empty():
		Global.spawn_pos_override = Global.player.global_position
