extends Node
class_name Inventory

var data : Dictionary = {}

signal item_added(item_id)
signal item_deleted(item_id)

var locked := false

func get_item_count() -> int:
	var item_count := 0
	
	for i in range(data.size()):
		var cur_key : String = data.keys()[i]
		var cur_amount : int = data[cur_key]
		
		item_count += cur_amount
	
	return item_count
	
func add_item(item_id : int):
	if locked: 
		return
	
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if not data.has(id_string):
		data[id_string] = 0
	
	data[id_string] += 1
	
	emit_signal("item_added", item_id)
	
func remove_item(item_id : int):
	if locked: 
		return
	
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if data.has(id_string):
		data[id_string] -= 1
		
		if data[id_string] <= 0:
			data.erase(id_string)
			
	emit_signal("item_deleted", item_id)
	
func wipe() -> int:
	if locked: 
		return 0
	
	var deletion_count := 0
	
	for i in range(ItemData.GameItems.size()):
		var item_def : ItemPickupDefinition = ItemData.get_definition(i)
		
		while data.has(item_def.identifier):
			remove_item(i)
			deletion_count += 1
			
	return deletion_count
		
