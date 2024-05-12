extends Pickup
class_name ItemPickup

var item_id : int = ItemData.GameItems.NULLABLE_ITEM

onready var pickbox : CollisionShape2D = $Pickbox
onready var sprite : Sprite = $Sprite

func _ready():
	pickbox.shape = ItemData.get_hitbox(item_id)
	sprite.texture = ItemData.get_sprite(item_id)
