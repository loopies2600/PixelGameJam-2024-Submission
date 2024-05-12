extends Node
class_name TextBoxManager

var tb : TextBox

var nameplate := ""
var portrait : Texture
var soundTable : Array
var pitchRange := Vector2.ONE
var soundMode : int = TextboxVoicePlayer.VoiceModes.PICK_RANDOM
var objectBind

func _freeTb():
	tb = null
	
func chatter(line):
	tb = Global.createTextbox(line, nameplate, portrait, soundTable, pitchRange, soundMode)
	
	if !tb: return
	
	var _unused = tb.connect("character_written", get_parent(), "characterWritten")
	_unused = tb.connect("typing_ended", get_parent(), "typingEnded")
	
	_unused = tb.connect("tree_exited", self, "_freeTb")
	
func setPortrait(tex : Texture = null):
	portrait = tex
	
func setNameplate(nmP := ""):
	nameplate = nmP
	
func setVoiceTable(sounds : Array):
	soundTable = sounds
	
func setVoiceMode(mode : int):
	soundMode = mode
	
func setVoicePitchRange(minR := 1.0, maxR := 1.0):
	pitchRange = Vector2(minR, maxR)
	
func bindObject(object):
	objectBind = object
