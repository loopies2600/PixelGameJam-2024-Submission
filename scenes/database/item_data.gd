extends Reference
class_name ItemData

enum GameItems {
	TEST_ITEM
}

static func get_identifier(item_id : int = 0) -> String:
	if item_id > GameItems.size(): return "null"
	if item_id < 0: return "null"
	
	return GameItems.keys()[item_id]
	
static func get_hitbox(item_id : int = 0) -> Shape2D:
	if item_id > GameItems.size(): return null
	if item_id < 0: return null
	
	return load("res://data/pickup/hitbox/item/item_hitbox_%s.tres" % item_id) as Shape2D
	
static func get_sprite(item_id : int = 0) -> Texture:
	if item_id > GameItems.size(): return null
	if item_id < 0: return null
	
	return load("res://assets/items/item_%s.png" % item_id) as Texture
