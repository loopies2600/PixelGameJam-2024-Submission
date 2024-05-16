extends Interactable
class_name KinematicActor

const ITEM_PICKUP_SCENE : PackedScene = preload("res://scenes/entity/pickup/item_pickup/item_pickup.tscn")
const HIT_STARS : PackedScene = preload("res://scenes/particles/hit_stars.tscn")
const GHOST_SPRITE : PackedScene = preload("res://scenes/particles/ghost_sprite.tscn")

signal attacked(victim, damage_amount)
signal took_damage(amount, attacker)
signal died(amount, attacker)

export (float) var base_speed := 128.0
export (float, 0.0, 0.99) var steering := 0.0
export (float, 0.0, 1.0) var damping := 0.8

export (int) var max_health := 10
export (int) var strength := 1

export (Array, int) var death_drops := []
export (float) var drops_delay := 0.001
export (Vector2) var max_item_spread := Vector2(-64, 64)

export (int) var loot_multiplier := 1

export (float) var tracking_distance := 128.0
export (float) var attack_distance := 32.0
export (int, LAYERS_2D_PHYSICS) var tracking_layers

var direction : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

var look_angle : Vector2 = Vector2.ZERO

var dead : bool = false
var attacking : bool = false
var frozen : bool = false
var parrying : bool = false
var invencible : bool = false

onready var health : int = max_health

var elapsed_alive := 0.0

func _ready():
	death_drops = death_drops.duplicate()
	
	connect("took_damage", self, "_on_damage_taken")
	connect("died", self, "_on_death")
	
func _on_damage_taken(damage_amount : int, source : Node):
	pass
	
func _on_death(damage_amount : int, source : Node):
	if not death_drops.empty():
		_drop_loot()
	
func _get_random_item_spread(max_spread := max_item_spread) -> Vector3:
	randomize()
	
	return Vector3(rand_range(max_spread.x, max_spread.y), rand_range(-128, -256), rand_range(max_spread.x, max_spread.y))
	
func _on_loot_dropped():
	queue_free()
	
func _drop_loot():
	var item_puke_timer := get_tree().create_timer(drops_delay)
	
	yield(item_puke_timer, "timeout")
	
	var current_item_id : int = death_drops.pop_back()
	var current_item_instance = ITEM_PICKUP_SCENE.instance()
	
	current_item_instance.position = global_position
	current_item_instance.velocity = _get_random_item_spread()
	
	get_parent().add_child(current_item_instance)
	
	current_item_instance.item_id = current_item_id
	
	if death_drops.size() > 0:
		_drop_loot()
	else:
		_on_loot_dropped()

func _on_successful_punch(target : KinematicActor):
	randomize()
	
	var star_amount := 4 + (randi() % 11)
	
	for j in range(star_amount):
		var new_hit_star = HIT_STARS.instance()
		
		new_hit_star.global_position = target.global_position
		get_parent().add_child(new_hit_star)
	
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
			scale.x = 1.0
		elif h_dir == -1:
			facing_name = "left"
			scale.x = -1.0
			
	return facing_name
	
func can_attack(target : KinematicActor) -> bool:
	if target.dead:
		return false
	
	return target.global_position.distance_squared_to(global_position) < pow(attack_distance, 2.0)
	
func find_player() -> bool:
	if Global.player.dead:
		return false
	
	var found := false
	
	var player_nearby := global_position.distance_squared_to(Global.player.global_position) <= pow(tracking_distance, 2.0)
	
	if player_nearby:
		var space_state := get_world_2d().direct_space_state
		
		var result := space_state.intersect_ray(global_position, Global.player.global_position, [self], tracking_layers)
		
		if result:
			if result.collider.name == Global.player.name:
				found = true
	
	return found
	
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
	
func attack(victim : KinematicActor, damage_amount := strength) -> bool:
	if frozen: return false
	if attacking: return false
	if dead: return false
	
	victim.take_damage(self, damage_amount)
	emit_signal("attacked", victim, damage_amount)
	_on_successful_punch(victim)
	
	return true
	
func take_damage(source, damage_amount : int):
	if invencible: return
	if parrying: return
	if frozen: return
	if dead: return
	if damage_amount <= 0: return
	
	damage_amount = clamp(damage_amount, 0, health)
	
	health -= damage_amount
	
	if health <= 0:
		dead = true
		emit_signal("took_damage", damage_amount, source)
		emit_signal("died", damage_amount, source)
	else:
		emit_signal("took_damage", damage_amount, source)
	
func get_walk_velocity() -> Vector2:
	if frozen: return Vector2.ZERO
	
	var new_velocity : Vector2 = direction * base_speed
	
	return velocity.linear_interpolate(new_velocity, 1.0 - steering)
	
func _process(delta):
	if not dead:
		elapsed_alive += delta
	
	if invencible:
		visible = !visible
	else:
		visible = true
	
	z_index = int(max(get_global_transform_with_canvas().origin.y, 0))
	
func _physics_process(delta):
	velocity = move_and_slide(velocity, Vector2.ZERO)
