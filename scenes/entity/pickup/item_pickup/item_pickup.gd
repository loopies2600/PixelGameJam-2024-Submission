extends Pickup
class_name ItemPickup

var item_id : int = ItemData.GameItems.TEST_ITEM

func _ready():
	pickbox.shape = ItemData.get_hitbox(item_id)
	sprite.texture = ItemData.get_sprite(item_id)

func _on_picked_up(body : Node):
	if body is PlayerActor:
		body.inventory.add_item(item_id)
		queue_free()
