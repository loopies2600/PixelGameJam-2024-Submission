extends CanvasLayer

const TYPEWRITER_DELAY := 0.4

onready var player_health_progress : TextureProgress = $QuexoteHealthbar/HealthProgress
onready var kh_label : Label = $KingHereLabel

onready var king_here_text : String = kh_label.text

var kh_string_copy := ""
var backwards := false
var removal_counter := 0

func _ready():
	kh_label.hide()
	
func show_king_is_here():
	if not visible: return
	
	kh_label.text = ""
	kh_string_copy = ""
	kh_label.show()
	removal_counter = 0
	
	_khl_add_char()
	
func _khl_add_char():
	var char_delay := get_tree().create_timer(TYPEWRITER_DELAY)
	
	yield(char_delay, "timeout")
	
	if kh_string_copy.length() < king_here_text.length():
		kh_string_copy += king_here_text[kh_label.text.length()]
	else:
		var removal_delay := get_tree().create_timer(TYPEWRITER_DELAY)
	
		yield(removal_delay, "timeout")
		
		_khl_remove_char()
		return
		
	kh_label.text = kh_string_copy
	
	_khl_add_char()
	
func _khl_remove_char():
	var char_delay := get_tree().create_timer(TYPEWRITER_DELAY)
	
	yield(char_delay, "timeout")
	
	kh_string_copy[removal_counter] = " "
	kh_label.text = kh_string_copy
	
	removal_counter += 1
	
	if not removal_counter >= king_here_text.length():
		_khl_remove_char()
	
func _process(delta):
	_update_health_progress()
	
func _update_health_progress():
	if Global.player == null:
		return
	
	player_health_progress.max_value = Global.player.max_health
	player_health_progress.value = Global.player.health
