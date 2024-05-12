extends CutsceneCommand
class_name CutsceneCommandTextbox

# MARSHALL (contenedor) PARA LAS CAJAS DE TEXTO
# Acá se hace MUCHO, así que vamos paso a paso

# Lista de comandos disponibles para transmitirle
# al sistema de cinemáticas
enum Commands {
	SPAWN, # commandType 			0
	SET_PORTRAIT, # commandType 	1
	SET_PITCH_RANGE, # commandType 	2
	SET_NAMEPLATE, # commandType 	3
	SET_VOICE_TABLE, # commandType 	4
	SET_VOICE_MODE # commandType 	5
	BIND_OBJECT # commandType 		6
	}
	
# ¿Qué función vamos a llamar?
var commandType : int

# Que variables vamos a pasarle a la función
# a modo de lista, esto lo define CutsceneBase.gd
# y no debería ser modificado manualmente.
var variableArray := []

# Usamos el gestor de cajas de textos de
# la cinemática, no necesitamos que cada
# comando cuente con una.
onready var tb = get_parent().textboxManager

func _init(cmdType : int, varray := []):
	commandType = cmdType
	variableArray = varray
	
# Todo esto es un marshall de las funciones
# de las cajas de texto. No es necesario
# ser un genio para entender que hacen a
# pesar de la organización diferente.
func run():
	match commandType:
		Commands.SPAWN:
			tb.chatter(variableArray[0])
			
			yield(tb.tb, "tree_exited")
		Commands.SET_PORTRAIT:
			tb.setPortrait(variableArray[0])
		Commands.SET_PITCH_RANGE:
			tb.setVoicePitchRange(variableArray[0], variableArray[1])
		Commands.SET_NAMEPLATE:
			tb.setNameplate(variableArray[0])
		Commands.SET_VOICE_TABLE:
			tb.setVoiceTable(variableArray[0])
		Commands.SET_VOICE_MODE:
			tb.setVoiceMode(variableArray[0])
		Commands.BIND_OBJECT:
			tb.bindObject(variableArray[0])
	
	yield(get_tree(), "idle_frame")
	emit_signal("finished")
