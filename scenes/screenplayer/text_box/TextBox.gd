extends CanvasLayer
class_name TextBox

const PORTRAITLESS_BOUNDS := Rect2(8, 180, 624, 113)
const PORTRAIT_BOUNDS := Rect2(64, 180, 512, 113)
const FLIP_MARGIN := 170

signal character_written(charPos)
signal typing_ended()

export (int) var baseCharacterDelay := 1

# USAR DE MODO = X: VALOR UNICODE Y: RETARDO (en frames)
# warning-ignore:export_hint_type_mistmatch
export (PoolVector2Array) var characterDelayTable = [
	Vector2(ord(' '), 2),
	Vector2(ord(','), 9),
	Vector2(ord('.'), 17),
	Vector2(ord('!'), 11),
	Vector2(ord('?'), 12)
]

var line : String
var lineStripped : String

onready var nameplate := $Nameplate
onready var message := $Text
onready var portrait := $Portrait
onready var mChoice := $MultipleChoice
onready var voice := $VoicePlayer
onready var nameplateTail = nameplate.get_stylebox("normal")
onready var parser := $ParsingTools

var nextCharCnt := baseCharacterDelay
var typingEnded := false setget _setTypingEnded
var msgMaxChars := 180

var charPos := 0
var flip := false
var autocompleteOn := -1

var waitTable := []

func _setTypingEnded(value : bool):
	if typingEnded == value:
		return
		
	typingEnded = value
	
	if typingEnded:
		emit_signal("typing_ended")
	
func _ready():
	Global.player.can_input = false
	
func _input(event):
	if mChoice.active: return
	
	if event.is_action_pressed("interact"):
		gotoNextLine()
	
func _process(delta):
	nextCharCnt -= 1
	
	if nextCharCnt == 0 && !typingEnded:
		emit_signal("character_written", charPos)
		
		var curChar = lineStripped[message.visible_characters]
		
		if message.visible_characters == autocompleteOn:
			gotoNextLine()
			return
		
		message.visible_characters += 1
		
		if curChar == " ":
			pass
		else:
			voice.play()
		
		nextCharCnt = _getCharacterDelay(message.visible_characters - 1)
		
		self.typingEnded = message.visible_characters == lineStripped.length()
	
func _getCharacterDelay(position : int) -> int:
	var character : String = lineStripped[position]
	
	for i in range(waitTable.size()):
		var wtEntry : Dictionary = waitTable[i]
		
		if position == wtEntry.char_position:
			return wtEntry.wait_frames
		
	var delay := baseCharacterDelay
	
	for i in range(characterDelayTable.size()):
		var charListEntry : int = characterDelayTable[i].x
		var charListEntryDelay : int = characterDelayTable[i].y
		
		if ord(character) == charListEntry:
			delay = charListEntryDelay
			
	return delay
	
func bindObject(object):
	parser.objBind = object
	
func gotoNextLine():
	if !typingEnded:
		message.visible_characters = -1
		self.typingEnded = true
		return
		
	destroy()
	
func refresh():
	waitTable.clear()
	
	charPos = 0
	nextCharCnt = baseCharacterDelay
	
	parser.parseCommands(parser.stripBBcode(line))
	
	message.bbcode_text = parser.stripCommands(line)
	lineStripped = parser.stripBBcode(message.bbcode_text)
	
	message.visible_characters = 0
	typingEnded = false
	
	portrait.visible = portrait.texture != null
	nameplate.visible = nameplate.text != ""
	
	var hasPortrait : bool = portrait.texture != null
	
	msgMaxChars = 180 if hasPortrait else 220
	
	message.rect_position = PORTRAIT_BOUNDS.position if hasPortrait else PORTRAITLESS_BOUNDS.position
	message.rect_size = PORTRAIT_BOUNDS.size if hasPortrait else PORTRAITLESS_BOUNDS.size
	
func destroy():
	queue_free()
	
func _exit_tree():
	Global.textbox = null
	
	Global.player.can_input = true
