extends KinematicActor

const ITEM_PICKUP_SCENE : PackedScene = preload("res://scenes/entity/pickup/item_pickup/item_pickup.tscn")
const PICKUP_SCENE : PackedScene = preload("res://scenes/entity/pickup/pickup.tscn")

const LID_SPRITE := preload("res://assets/sprites/objects/spr_chest_lid.png")
const LOCK_SPRITE := preload("res://assets/sprites/objects/spr_chest_lock.png")

# Ids de items individuales
export (PoolIntArray) var contents := []
export (Vector2) var max_item_spread := Vector2(-64, 64)

onready var anim : AnimationPlayer = $AnimationPlayer
onready var item_puke_timer : Timer = $ItemPukeTimer

func _on_damage_taken(damage_amount, source):
	anim.stop(true)
	anim.play("TakeDamage")
	
func _on_death(damage_amount, source):
	anim.play("DamageOpen")
	
	$Collision.call_deferred("set_disabled", true)
	
	_animate_lid()
	
	item_puke_timer.start()
	
	yield(item_puke_timer, "timeout")
	
	_puke_contents()
	
func _get_random_velocity(max_spread := max_item_spread) -> Vector3:
	randomize()
	
	return Vector3(rand_range(max_spread.x, max_spread.y), rand_range(-128, -256), rand_range(max_spread.x, max_spread.y))
	
func _animate_lid():
	var lid_pickup = PICKUP_SCENE.instance()
	var lock_pickup = PICKUP_SCENE.instance()
	
	lock_pickup.position = global_position
	lid_pickup.position = global_position
	
	lid_pickup.velocity = _get_random_velocity(max_item_spread / 4.0)
	lock_pickup.velocity = _get_random_velocity(max_item_spread / 2.0)
	
	get_parent().add_child(lid_pickup)
	get_parent().add_child(lock_pickup)
	
	lid_pickup.sprite.texture = LID_SPRITE
	lock_pickup.sprite.texture = LOCK_SPRITE
	
func _puke_contents():
	if contents.size() == 0: return
	
	item_puke_timer.start()
	
	yield(item_puke_timer, "timeout")
	
	var current_item_id : int = contents.pop_back()
	var current_item_instance = ITEM_PICKUP_SCENE.instance()
	
	current_item_instance.position = global_position
	current_item_instance.velocity = _get_random_velocity()
	
	get_parent().add_child(current_item_instance)
	
	if contents.size() != 0:
		_puke_contents()
