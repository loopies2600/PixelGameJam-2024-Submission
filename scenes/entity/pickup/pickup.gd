extends Area2D
class_name Pickup

export (float) var base_gravity := 9.8
export (float) var damping := 0.8
export (float) var pickbox_delay := 1.0

var velocity : Vector3 = Vector3.ZERO

onready var position_3d : Vector3 = Vector3(position.x, 0.0, position.y)

onready var pickbox : CollisionShape2D = $Pickbox
onready var sprite : Sprite = $Sprite

var lifetime := 0.0

func _ready():
	monitoring = false
	monitorable = false
	
	var pick_delay_timer := get_tree().create_timer(pickbox_delay)
	
	yield(pick_delay_timer, "timeout")
	
	monitoring = true
	monitorable = true
	
	connect("body_entered", self, "_on_picked_up")
	
func _process(delta):
	lifetime += delta
	
	z_index = int(max(get_global_transform_with_canvas().origin.y - position_3d.y, 0))
	
	# kill after 5 mins
	if lifetime > (5.0 * 60.0):
		queue_free()
	
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
	
func _on_picked_up(body : Node):
	pass
