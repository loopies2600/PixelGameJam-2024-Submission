extends Node
class_name Cutscene, "res://assets/screenplayer/icons/clapboard.png"

var currentSequence := "sequence"

onready var cam : Camera2D = Global.player.cam

func sequence():
	pass
	
func getCurrentCommand() -> CutsceneCommand:
	return CutsceneManager.currentCommand
	
func getLastCommandResult() -> Array:
	return CutsceneManager.commandResultBuffer
	
func execute():
	call(currentSequence)
	
	CutsceneManager.name = get_script().get_path().get_file().get_basename() + "->" + currentSequence
	
	yield(CutsceneManager.execute(), "completed")
	
func sleep(timeSec := 0.0):
	# Vas a notar que estas funciones tienen una estructura muy similar
	# Pues son wrappers, así que no voy a explicar su uso dentro de este script.
	var cmd := CutsceneCommandDelay.new(timeSec)
	
	CutsceneManager.commands.append(cmd)
	
func tweenSetTransition(type : int):
	var typeWrapped = wrapi(type, 0, Tween.TRANS_BACK)
	
	CutsceneManager.tweenerTransType = typeWrapped
	
func tweenSetEasing(type : int):
	var typeWrapped = wrapi(type, 0, Tween.EASE_OUT_IN)
	
	CutsceneManager.tweenerEaseType = typeWrapped
	
func moveNode(node : Node2D, position : Vector2, timeSec := 1.0):
	var cmd := CutsceneCommandMoveNode.new(
		node, 
		position, 
		timeSec,
		CutsceneManager.tweenerTransType,
		CutsceneManager.tweenerEaseType)
	
	CutsceneManager.commands.append(cmd)
	
func callSeq(object, method : String, varArg := []):
	var cmd := CutsceneCommandCall.new(object, method, varArg)
	
	CutsceneManager.commands.append(cmd)
	
func setParallel(on : bool):
	setVar(CutsceneManager, "parallel", on)
	
func setVar(object, variable : String, value):
	var cmd := CutsceneCommandSetProperty.new(object, variable, value)
	
	CutsceneManager.commands.append(cmd)
	
func moveCam(pos := Vector2.ZERO, timeSec := 0.0, globalCoords := false):
	var finalPos : Vector2 = pos + Global.player.CAMERA_OFFSET
	
	if globalCoords:
		finalPos -= Global.player.global_position
	
	moveNode(cam, finalPos, timeSec)
	
func camReset(timeSec := 0.0):
	moveNode(cam, Global.player.position + Global.player.CAMERA_OFFSET, timeSec)
	
func chatter(line : String):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SPAWN, 
		[line])
	
	CutsceneManager.commands.append(cmd)
	
func setPortrait(tex : Texture = null):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SET_PORTRAIT, 
		[tex])

	CutsceneManager.commands.append(cmd)
	
func setNameplate(nmP := ""):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SET_NAMEPLATE, 
		[nmP])

	CutsceneManager.commands.append(cmd)
	
func setVoiceTable(sounds : Array):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SET_VOICE_TABLE, 
		[sounds])

	CutsceneManager.commands.append(cmd)
	
func setVoiceMode(mode : int):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SET_VOICE_MODE, 
		[mode])

	CutsceneManager.commands.append(cmd)
	
func setVoicePitchRange(minR := 1.0, maxR := 1.0):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.SET_PITCH_RANGE, 
		[minR, maxR])
	
	CutsceneManager.commands.append(cmd)
	
func textboxBindObject(object):
	var cmd := CutsceneCommandTextbox.new(
		CutsceneCommandTextbox.Commands.BIND_OBJECT, 
		[object])
	
	CutsceneManager.commands.append(cmd)
	
func instantiate(scenePath : String, waitSignal := "", parent := get_tree().current_scene, propertyOverrides := {}):
	var cmd := CutsceneCommandInstantiate.new(
		scenePath,
		waitSignal,
		parent,
		propertyOverrides
	)
	
	CutsceneManager.commands.append(cmd)
	
func changeSequence(newSeqMethod := "sequence", stopCurrent := true):
	var cmd := CutsceneCommandResetCutscene.new(stopCurrent, self, newSeqMethod)
	
	CutsceneManager.commands.append(cmd)
	
func playSound(soundPath := ""):
	callSeq(Global, "play_sound", [soundPath])
