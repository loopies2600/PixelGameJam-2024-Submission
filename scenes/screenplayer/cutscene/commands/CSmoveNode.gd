extends CutsceneCommand
class_name CutsceneCommandMoveNode

# --- CS COMMAND MOVE NODE ---
# Traslada un nodo y detiene la ejecución
# hasta que este llegue a destino

# Victima
var node : Node2D

# Punto final
var position : Vector2

# Duración
var timeSec := 1.0

# Parametros del Tween
var easingType := Tween.EASE_IN
var transitionType := Tween.TRANS_LINEAR

func _init(n : Node2D, pos : Vector2, time := 1.0, trans := Tween.TRANS_LINEAR, easing := Tween.EASE_IN_OUT):
	node = n
	position = pos
	timeSec = time
	easingType = easing
	transitionType = trans
	
func run():
	var tweener := create_tween()
	
	tweener.set_ease(easingType)
	tweener.set_trans(transitionType)
	
	var _unused = tweener.tween_property(node, "global_position", position, timeSec)
	
	yield(tweener, "finished")
	
	result = [node.global_position]
	
	emit_signal("finished")
