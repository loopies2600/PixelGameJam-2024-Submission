extends Bullet

export (int, LAYERS_2D_PHYSICS) var parry_layers = 8

onready var parry_zone : ShapeCast2D = $ParryZone

var parried := false

func _ready():
	set("playing", true)

func _check_hit():
	if parried:
		hitbox.collision_mask = parry_layers
	
	var actor_ids := _scan_for_actors(hitbox)
	
	for i in range(actor_ids.size()):
		var instance = instance_from_id(actor_ids[i])
		
		if instance is KinematicActor:
			if instance.dead or instance.attacking:
				continue
			
			if parried:
				Global.player._on_successful_punch(instance)
			
			instance.take_damage(self, damage)
			queue_free()
	
func _check_parry():
	var actor_ids := _scan_for_actors(parry_zone)
	
	for i in range(actor_ids.size()):
		var instance = instance_from_id(actor_ids[i])
		
		if instance is KinematicActor:
			if not instance.attacking:
				continue
			
			instance._on_successful_punch($FakeActor)
			
			elapsed_alive = 0.0
			
			velocity = base_speed * instance.look_angle.normalized()
			parried = true
	
func check_collision():
	_check_parry()
	_check_hit()
