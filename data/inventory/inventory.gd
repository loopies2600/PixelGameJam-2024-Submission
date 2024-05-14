extends Node
class_name Inventory

var data : Dictionary = {}

func add_item(item_id : int):
	var id_string := ItemData.get_identifier(item_id)
	
	if not data.has(id_string):
		data[id_string] = 0
	
	data[id_string] += 1
	
	print(data)
	
func remove_item(item_id : int):
	var id_string := ItemData.get_identifier(item_id)
	
	if data.has(id_string):
		data[id_string] += 1
		
		if data[id_string] <= 0:
			data.erase(id_string)
