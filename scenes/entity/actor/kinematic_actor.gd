extends KinematicBody2D
class_name KinematicActor

signal took_damage(amount, attacker)
signal died(amount, attacker)

export (float) var base_speed := 128.0
export (float, 0.0, 0.99) var steering := 0.0
export (float, 0.0, 1.0) var damping := 0.8

export (int) var max_health := 10
export (int) var strength := 1

var direction : Vector2 = Vector2.ZERO
var velocity : Vector2 = Vector2.ZERO

var health : int = max_health

var dead : bool = false
var attacking : bool = false

func _ready():
	connect("took_damage", self, "_on_damage_taken")
	connect("died", self, "_on_death")
	
func _on_damage_taken(damage_amount, source):
	pass
	
func _on_death(damage_amount, source):
	queue_free()
	
func attack(victim : KinematicActor, damage_amount := strength):
	if attacking: return
	
	victim.take_damage(self, damage_amount)
	
	attacking = true
	
func take_damage(source, damage_amount : int):
	if dead: return
	if damage_amount <= 0: return
	
	damage_amount = clamp(damage_amount, 0, health)
	
	health -= damage_amount
	
	if health <= 0:
		dead = true
		emit_signal("died", damage_amount, source)
	else:
		emit_signal("took_damage", damage_amount, source)
	
func get_walk_velocity() -> Vector2:
	var new_velocity : Vector2 = direction * base_speed
	
	return velocity.linear_interpolate(new_velocity, 1.0 - steering)
	
func _process(delta):
	z_index = int(max(get_global_transform_with_canvas().origin.y, 0))
	
func _physics_process(delta):
	velocity = get_walk_velocity()
	
	velocity = move_and_slide(velocity, Vector2.ZERO)
