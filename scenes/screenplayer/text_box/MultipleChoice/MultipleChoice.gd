extends MarginContainer

const OPTION_LABEL := preload("res://scenes/screenplayer/text_box/MultipleChoice/OptionLabel.tscn")
const OFFSET := Vector2(320, 175)

signal decision_made(idx, pageNum)

var options := PoolStringArray()
var active := false
var scrollingSelector : ScrollingSelector

onready var choicesContainer := $ChoicesContainer

func _init():
	visible = false
	
func popup(choices := PoolStringArray()):
	clear()
	
	if !choices && !options: return
	
	visible = true
	
	for opt in choices:
		options.append(opt)
		
		var newOption := OPTION_LABEL.instance()
		newOption.text = opt
		
		choicesContainer.add_child(newOption)
	
	scrollingSelector = ScrollingSelector.new(0, options.size())
	add_child(scrollingSelector)
	
	var _unused = scrollingSelector.connect("decision_made", self, "makeSelection")
	
	active = true
	
func _process(_delta):
	rect_position = OFFSET - (rect_size / 2)
	
	update()
	
func makeSelection(idx := 0):
	emit_signal("decision_made", idx, get_parent().msgIdx)
	
	# WAIT A SINGLE FRAME so inputs don't intersect
	yield(get_tree(), "idle_frame")
	
	active = false
	visible = false
	
func clear():
	options.clear()
	
	for i in range(choicesContainer.get_child_count()):
		choicesContainer.get_child(i).queue_free()
	
func _checkNEscapes(string : String) -> int:
	var newlineCnt := string.count("\n", 0, string.length())
	
	return newlineCnt + 1
	
func _draw():
	if !options: return
	
	var heightMultiplier := _checkNEscapes(options[scrollingSelector.selected])
	
	draw_rect(Rect2(0, 32 * scrollingSelector.selected, rect_size.x, 32 * heightMultiplier), Color.indigo, true)
	
