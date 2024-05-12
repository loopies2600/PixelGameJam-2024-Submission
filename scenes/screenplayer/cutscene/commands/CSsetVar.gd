extends CutsceneCommand
class_name CutsceneCommandSetProperty

# --- CS COMMAND SET PROPERTY ---
# Redefine una variable perteneciente a cualquier objeto.

# Victima
var object

# Propiedad (variable)
var property : String

# Valor a asignar
var value

func _init(obj, prp : String, val):
	object = obj
	property = prp
	value = val
	
func run():
	object.set(property, value)
	
	yield(get_tree(), "idle_frame")
	
	result = [object.get(property)]
	
	emit_signal("finished")
