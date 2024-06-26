extends KinematicBody2D 
class_name Interactable, "res://assets/screenplayer/icons/interactable.png"

export (int) var cutsceneEvent = 0

var interacting := false

func interact():
	if interacting:
		return
	
	interacting = true
	
	yield(runEvents(), "completed")
	
	interacting = false
	
func runEvents():
	var cutscenes := []
	
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is Cutscene:
			cutscenes.append(child)
		
	if cutsceneEvent > cutscenes.size() - 1 || cutsceneEvent < 0:
		yield(get_tree(), "idle_frame")
		
		return
		
	var selectedCutscene : Cutscene = cutscenes[cutsceneEvent]
	var functionState : GDScriptFunctionState = selectedCutscene.execute()
	
	yield(functionState, "completed")
