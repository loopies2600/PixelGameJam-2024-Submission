extends Node
class_name CutsceneCommand

# --- CLASE BASE DE COMANDO DE CINEMÁTICAS ---
# * no hace nada *

# warning-ignore:unused_signal
signal finished()

onready var parallel : bool = CutsceneManager.parallel
var result := []

func abort():
	emit_signal("finished")
	
func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			queue_free()
			
func run():
	pass
