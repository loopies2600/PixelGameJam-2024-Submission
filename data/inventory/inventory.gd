extends Node
class_name Inventory

var data : Dictionary = {}

func get_item_count() -> int:
	var item_count := 0
	
	for i in range(data.size()):
		var cur_key : String = data.keys()[i]
		var cur_amount : int = data[cur_key]
		
		item_count += cur_amount
	
	return item_count
	
func add_item(item_id : int):
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if not data.has(id_string):
		data[id_string] = 0
	
	data[id_string] += 1
	
	print(get_item_count())
	
func remove_item(item_id : int):
	var item_def : ItemPickupDefinition = ItemData.get_definition(item_id)
	var id_string := item_def.identifier
	
	if data.has(id_string):
		data[id_string] += 1
		
		if data[id_string] <= 0:
			data.erase(id_string)
