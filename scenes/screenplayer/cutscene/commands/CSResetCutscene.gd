extends CutsceneCommand
class_name CutsceneCommandResetCutscene

# --- CS COMMAND DELAY ---
# Detiene la ejecución hasta que el temporizador finalice.

# Duración del temporizador.
var cutsceneInstance
var newSequenceMethod := "sequence"
var stop := true

func _init(_stop := true, _csi = null, _nsm := "sequence"):
	cutsceneInstance = _csi
	newSequenceMethod = _nsm
	stop = _stop
	
func run():
	cutsceneInstance.currentSequence = newSequenceMethod
	var executeCutRef := funcref(cutsceneInstance, "execute")
	
	if stop:
		executeCutRef = null
	
	CutsceneManager.forceEnd(executeCutRef)
