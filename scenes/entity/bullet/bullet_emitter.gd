tool
extends Node2D

const BULLETS := [
	preload("res://scenes/entity/bullet/bullet_basic_small.tscn"),
	preload("res://scenes/entity/bullet/bullet_basic_big.tscn"),
	preload("res://scenes/entity/bullet/bullet_parry_small.tscn"),
	preload("res://scenes/entity/bullet/bullet_parry_big.tscn")
]

enum BulletType {
	BASIC_SMALL,
	BASIC_BIG,
	PARRY_SMALL,
	PARRY_BIG
}

export (BulletType) var bullet_type : int = 0
export (int, 1, 1000) var bullet_count := 16
export (float) var bullet_base_speed := 128.0
export (float) var per_bullet_delay := 0.0

export (float, 0.0, 6.283185) var start_angle := 0.0
export (float, 0.0, 6.283185) var spread := TAU

var instance_counter := 0
var elapsed := 0.0
var enabled := false

func _process(delta):
	if enabled:
		elapsed += delta
		
		var angles := get_bullet_angles()
		
		if elapsed > per_bullet_delay:
			var cur_angle := angles[instance_counter]
			
			_spawn_bullet(cur_angle)
			
			elapsed = 0.0
			
			instance_counter += 1
			
			if instance_counter >= angles.size():
				enabled = false
	
	update()
	
func _spawn_bullet(angle : float):
	var bullet_instance = BULLETS[bullet_type].instance()
	
	bullet_instance.base_speed = bullet_base_speed
	bullet_instance.velocity = Vector2.RIGHT.rotated(angle) * bullet_instance.base_speed
	
	bullet_instance.global_transform = global_transform
	
	add_child(bullet_instance)
	bullet_instance.set_as_toplevel(true)
	
func fire():
	instance_counter = 0
	enabled = true
	
func get_bullet_angles() -> PoolRealArray:
	var angles : PoolRealArray = []
	
	var current_angle := start_angle
	
	for i in range(bullet_count):
		current_angle += spread / bullet_count
		
		angles.append(current_angle)
	
	return angles
	
func _draw():
	if not Engine.editor_hint:
		return
	
	var angles := get_bullet_angles()
	
	for i in range(angles.size()):
		var cur_angle := angles[i]
		
		draw_line(Vector2.ZERO, Vector2(32.0, 0.0).rotated(cur_angle), Color.red, 1.25)
