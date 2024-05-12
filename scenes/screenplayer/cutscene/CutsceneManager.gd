extends Node

# Señal emitida una vez activada la cinemática
signal cutscene_started()

# Señal emitida cuando se finalizan todos los pasos
signal cutscene_ended()

# Señal emitida una vez que termine un paso
signal step_started(cmdIdx)
signal step_ended(cmdIdx)

# Si es verdadero, va a ejecutar varios pasos
# a la vez
var parallel : bool = false

# Lista de todos los pasos que se usarán
# NUNCA modificar a mano, las funciones
# de pasos llenarán su contenido
var commands := []
var commandResultBuffer := []

var commandIndex := 0
# Chequea esta variable para saber si la cinemática
# está en proceso
var running := false

# Gestor de cajas de texto.
# Usado para chatter()
var textboxManager = preload("res://scenes/screenplayer/text_box/TextboxManager.gd").new()

# Para moveNode()
var tweenerEaseType := Tween.EASE_IN
var tweenerTransType := Tween.TRANS_LINEAR

func _ready():
	# Una vez que el objeto de cinemática esté
	# listo podemos instanciar el gestor
	add_child(textboxManager)
	
func execute():
	commandIndex = 0
	# Llama esta función cuando quieras empezar
	# la ejecución de una cinemática.
	# Es usada por el área CutsceneTrigger 
	# cuando el jugador se posa sobre él.
	# Acá es donde llamamos a sequence()
	# para analizar y registrar cada comando (paso)
	# de la cinemática.
	
	# Si no hay comandos no necesitamos ejecutar todo lo demás
	if commands.size() == 0:
		yield(get_tree(), "idle_frame")
		return
	
	running = true
	
	# Avisemos que empezamos.
	# Volquemos en la consola el nombre de la cinemática.
	emit_signal("cutscene_started")
	
	# sequence() de por sí no ejecuta los comandos.
	# _cmdExec() lo hace, y acá lo que haremos
	# es esperar que la función termine por completo
	yield(_cmdExec(), "completed")
	
	# Este ya es un punto seguro para avisar
	# que la cinemática terminó, volquemos el nombre
	# por si las moscas.
	emit_signal("cutscene_ended")
	
	# Oficialmente terminamos y csTick() será ignorado.
	running = false
	
	# Cada comando es un objeto, para reducir la carga
	# acá debemos borrar todo, del mismo modo con esto
	# aseguramos que podremos repetir la cinemática
	# sin problemas en caso de que lo necesitemos.
	_cleanup()
	
func characterWritten(_charPos : int):
	pass
	
func typingEnded():
	pass
	
func forceEnd(callback : FuncRef = null):
	emit_signal("cutscene_ended")
	
	running = false
	
	_cleanup()
	
	if callback:
		callback.call_func()

func _cmdExec():
	# Acá dentro vamos a ir por cada miembro
	# de la lista de comandos y ejecutarlos.
	# Todo con el fin de asegurar el orden correcto.
	while commandIndex < commands.size():
		var cmd : CutsceneCommand = commands[commandIndex]
		
		add_child(cmd)
		
		cmd.run()
		emit_signal("step_started", commandIndex)
		
		if !parallel:
			yield(cmd, "finished")
		
		emit_signal("step_ended", commandIndex)
		commandResultBuffer = cmd.result
		
		commandIndex += 1
		
func _cleanup():
	# En la función anterior tuvimos que instanciar
	# cada comando. Ya no los vamos a usar una vez
	# terminada la cinemática así que vamos a borarlos
	# y también vaciar la lista de comandos.
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is CutsceneCommand:
			child.queue_free()
		
	commands.clear()
