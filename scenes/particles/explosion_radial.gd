extends Node2D

const HIT_STARS : PackedScene = preload("res://scenes/particles/hit_stars.tscn")

export (float) var lifetime := 0.5
export (float) var radius := 48.0
export (Color) var color := Color.white
export (bool) var spawn_stars := true
export (Vector2) var stars_amount := Vector2(4, 15)
export (float) var star_speed := 128.0

var elapsed := 0.0

func _ready():
	yield(get_tree(), "idle_frame")
	
	if spawn_stars:
		_spawn_stars()
	
func _spawn_stars():
	randomize()
	
	var star_amount := int(stars_amount.x) + (randi() % int(stars_amount.y - stars_amount.x))
	
	for j in range(star_amount):
		var new_hit_star = HIT_STARS.instance()
		
		new_hit_star.randomize_pos = false
		
		new_hit_star.global_position = global_position
		new_hit_star.velocity = Vector3.RIGHT.rotated(Vector3.DOWN, rand_range(0.0, TAU)) * star_speed
		
		get_parent().add_child(new_hit_star)
	
func _process(delta):
	update()
	
	elapsed += delta
	modulate.a = (lifetime - elapsed) / lifetime
	
	if elapsed >= lifetime:
		queue_free()
	
func _draw():
	draw_circle(Vector2.ZERO, radius * (elapsed / lifetime), color)
