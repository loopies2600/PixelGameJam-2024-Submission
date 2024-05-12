extends Node
class_name ScrollingSelector

signal selection_changed(idx)
signal decision_made(idx)

var selected := 0 setget _setSelected
var maxOptions := 0
var consumable := true

func _setSelected(value : int):
	if selected == value: return
	
	selected = value
	emit_signal("selection_changed", selected)
	
func _init(_selected := 0, _maxOpt := 0, _cnsm := true):
	selected = _selected
	maxOptions = _maxOpt
	consumable = _cnsm
	
func _enter_tree():
	emit_signal("selection_changed", selected)
	
func _input(event):
	var direction := 0
	
	if event.is_action_pressed("ui_up", true):
		direction = -1
	if event.is_action_pressed("ui_down", true):
		direction = 1
	if event.is_action_pressed("interact"):
		emit_signal("decision_made", selected)
		
		if consumable:
			queue_free()
		
	self.selected = wrapi(selected + direction, 0, maxOptions)
