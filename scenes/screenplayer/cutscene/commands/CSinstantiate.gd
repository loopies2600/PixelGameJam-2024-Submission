extends CutsceneCommand
class_name CutsceneCommandInstantiate

# --- CS INSTANTIATE ---
# Cargar una escena y spawnearla donde sea
# Opcionalmente la esperamos con una señal...!

var scenePath : String
var waitSignal := ""
var parent : Node
var propertyOverides := {}

func _init(path : String, wSig := "", myPar := get_tree().current_scene, propOverr := {}):
	scenePath = path
	waitSignal = wSig
	parent = myPar
	propertyOverides = propOverr
	
func run():
	var packedScene : PackedScene = load(scenePath)
	var newInstance := packedScene.instance()
	
	for p in range(propertyOverides.keys().size()):
		print(p)
		
	parent.add_child(newInstance)
	
	if waitSignal:
		yield(newInstance, waitSignal)
	else:
		yield(get_tree(), "idle_frame")
		
	result = [newInstance]
	
	emit_signal("finished")
