extends CutsceneCommand
class_name CutsceneCommandCall

# Esta mierda se volvió más complicada de lo que debería
# --- CS COMMAND CALL ---
# Llama a una función mientras se mantiene en la secuencia.

# Victima
var object : Node

# Propiedad (variable)
var method : String

# Valor a asignar
var varArg := []

func _init(obj, met : String, vars := []):
	object = obj
	method = met
	varArg = vars
	
func run():
	var fState = object.callv(method, varArg)
	
	if fState is GDScriptFunctionState:
		yield(fState, "completed")
	else:
		yield(get_tree(), "idle_frame")
		
	result = [fState]
	
	emit_signal("finished")
