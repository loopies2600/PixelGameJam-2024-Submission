extends CutsceneCommand
class_name CutsceneCommandDelay

# --- CS COMMAND DELAY ---
# Detiene la ejecución hasta que el temporizador finalice.

# Duración del temporizador.
var time := 0.0

func _init(tsec := 0.0):
	time = tsec
	
func run():
	var timer := get_tree().create_timer(time, false)
	
	yield(timer, "timeout")
	
	emit_signal("finished")
