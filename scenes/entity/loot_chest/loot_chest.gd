extends KinematicActor

const PICKUP_SCENE : PackedScene = preload("res://scenes/entity/pickup/pickup.tscn")

const LID_SPRITE := preload("res://assets/sprites/objects/spr_chest_lid.png")
const LOCK_SPRITE := preload("res://assets/sprites/objects/spr_chest_lock.png")

export (Vector2) var random_fish_loot_amount := Vector2(20, 20)

onready var anim : AnimationPlayer = $AnimationPlayer

func _ready():
	death_drops = death_drops.duplicate()
	
	death_drops.clear()
	
	var random_amount := int(rand_range(random_fish_loot_amount.x, random_fish_loot_amount.y))
	
	for i in range(random_amount):
		var random_integer : int = randi() % ItemData.GameItems.size()
		
		death_drops.append(random_integer)
	
func _on_damage_taken(damage_amount, source):
	anim.stop(true)
	anim.play("TakeDamage")
	
func _on_loot_dropped():
	pass
	
func _on_death(damage_amount, source):
	anim.play("DamageOpen")
	
	$Collision.call_deferred("set_disabled", true)
	
	_animate_lid()
	
	_drop_loot()
	
func _animate_lid():
	var lid_pickup = PICKUP_SCENE.instance()
	var lock_pickup = PICKUP_SCENE.instance()
	
	lock_pickup.position = global_position
	lid_pickup.position = global_position
	
	lid_pickup.velocity = _get_random_item_spread(max_item_spread / 4.0)
	lock_pickup.velocity = _get_random_item_spread(max_item_spread / 2.0)
	
	get_parent().add_child(lid_pickup)
	get_parent().add_child(lock_pickup)
	
	lid_pickup.sprite.texture = LID_SPRITE
	lock_pickup.sprite.texture = LOCK_SPRITE
