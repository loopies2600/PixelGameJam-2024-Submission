extends Reference
class_name ItemData

const ITEM_DEFINITIONS := [
	preload("res://data/pickup/item/dummy_fish.tres"),
	preload("res://data/pickup/item/red_fish.tres")
]

enum GameItems {
	TEST_ITEM,
	RED_FISH
}

static func get_definition(item_id : int = 0) -> ItemPickupDefinition:
	item_id = clamp(item_id, 0, GameItems.size() - 1)
	
	return ITEM_DEFINITIONS[item_id]
