extends Label

var time := 0.0

func _process(delta):
	time = get_tree().current_scene.king_timer.time_left
	
	refreshTime()
	
func refreshTime():
	var frac = (time - floor(time)) * 100.0
	var sec := fmod(time, 60.0)
	var minutes := fmod(time / 60.0, 60.0)
	var hour := (time / 60.0) / 60.0
	
	text = "%02d:%02d" % [minutes, sec]
