extends Node
class_name Inventory

var data : Dictionary = {}

func add_item(item_id : int):
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if not data.has(id_string):
		data[id_string] = 0
	
	data[id_string] += 1
	
	print(data)
	
func remove_item(item_id : int):
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if data.has(id_string):
		data[id_string] += 1
		
		if data[id_string] <= 0:
			data.erase(id_string)
