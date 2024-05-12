extends KinematicActor

const ITEM_PICKUP_SCENE : PackedScene = preload("res://scenes/entity/pickup/item_pickup/item_pickup.tscn")

# Ids de items individuales
export (PoolIntArray) var contents := []
export (Vector2) var max_item_spread := Vector2(-128, 128)

onready var anim : AnimationPlayer = $AnimationPlayer
onready var item_puke_timer : Timer = $ItemPukeTimer

func _on_damage_taken(damage_amount, source):
	anim.stop(true)
	anim.play("TakeDamage")
	
func _on_death(damage_amount, source):
	anim.play("DamageOpen")
	
	$Collision.call_deferred("set_disabled", true)
	
	_puke_contents()
	
func _puke_contents():
	randomize()
	
	if contents.size() == 0: return
	
	item_puke_timer.start()
	
	yield(item_puke_timer, "timeout")
	
	var current_item_id : int = contents.pop_back()
	var current_item_instance = ITEM_PICKUP_SCENE.instance()
	
	var rand_vel_x := rand_range(max_item_spread.x, max_item_spread.y)
	var rand_vel_y := rand_range(-128, -256)
	var rand_vel_z := rand_range(max_item_spread.x, max_item_spread.y)
	
	current_item_instance.position = global_position
	current_item_instance.velocity = Vector3(rand_vel_x, rand_vel_y, rand_vel_z)
	
	get_parent().add_child(current_item_instance)
	
	if contents.size() != 0:
		_puke_contents()
