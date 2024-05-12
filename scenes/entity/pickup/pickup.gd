extends Area2D
class_name Pickup

export (float) var base_gravity := 9.8
export (float) var damping := 0.8

var velocity : Vector3 = Vector3.ZERO

onready var position_3d : Vector3 = Vector3(position.x, 0.0, position.y)

func _ready():
	connect("body_entered", self, "_on_picked_up")
	
func _process(_delta):
	z_index = int(max(get_global_transform_with_canvas().origin.y - position_3d.y, 0))
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += base_gravity
	else:
		velocity.x *= damping
		velocity.z *= damping
		
	position_3d += velocity * delta
	
	position = Vector2(position_3d.x, position_3d.z + position_3d.y)
	
func is_on_floor() -> bool:
	if position_3d.y >= 0.0:
		position_3d.y = 0.0
		
	return position_3d.y >= 0.0
	
func _on_picked_up(body):
	queue_free()
