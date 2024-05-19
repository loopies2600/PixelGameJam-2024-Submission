extends AnimatedSprite

export (float) var lifetime := 1.1
export (float) var gravity := 7.0

export (Vector2) var random_impulse := Vector2(-32, 32)
export (float) var random_jump := 128

export (bool) var randomize_pos := true

onready var position_3d : Vector3 = Vector3(position.x, 0.0, position.y)
onready var base_scale : Vector2 = scale

var elapsed := 0.0
var velocity : Vector3 = Vector3.ZERO

func _ready():
	if randomize_pos:
		randomize()
		
		velocity.x = rand_range(random_impulse.x, random_impulse.y)
		velocity.y = rand_range(-random_jump, -(random_jump / 4.0))
		velocity.z = (rand_range(random_impulse.x, random_impulse.y)) / 2.0
		
	animation = Array(frames.get_animation_names()).pick_random()
	playing = true
	
func _process(delta):
	elapsed += delta
	
	z_index = int(clamp(get_global_transform_with_canvas().origin.y - position_3d.y, 0, VisualServer.CANVAS_ITEM_Z_MAX))
	
	scale = base_scale * ((lifetime - elapsed) / lifetime)
	if elapsed > lifetime:
		queue_free()
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity
	
	position_3d += velocity * delta
	
	position = Vector2(position_3d.x, position_3d.z + position_3d.y)
	
func is_on_floor() -> bool:
	if position_3d.y >= 0.0:
		position_3d.y = 0.0
		
	return position_3d.y >= 0.0
