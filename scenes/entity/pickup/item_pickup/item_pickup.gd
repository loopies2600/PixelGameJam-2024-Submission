extends Pickup
class_name ItemPickup

var item_id : int = ItemData.GameItems.TEST_ITEM setget _set_item_id

onready var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)

func _set_item_id(value : int):
	item_id = value
	
	_refresh_pickup()
	
func _ready():
	_refresh_pickup()
	
func _refresh_pickup():
	item_def = ItemData.get_definition(item_id)
	
	pickbox.shape = item_def.collision_box
	sprite.texture = item_def.sprite

func _on_picked_up(body : Node):
	if body.name == Global.player.name:
		if body.inventory.locked:
			return
		
		body.inventory.add_item(item_id)
		queue_free()
