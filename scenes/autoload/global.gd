extends Node

const TB_SCENE := preload("res://scenes/screenplayer/text_box/TextBox.tscn")
const MAINFONT := preload("res://assets/screenplayer/fonts/aquarius_monospace.tres")
const PLAYER_SCENE := preload("res://scenes/entity/player/player.tscn")
const KING_SCENE := preload("res://scenes/entity/god_himself/KING.tscn")

var textbox : TextBox
var _tbBgOffset : Vector2 = Vector2.ZERO
var focusActor : Node2D = null

var exiting : bool = false
var transitioning : bool = false

onready var player : PlayerActor = PLAYER_SCENE.instance() as PlayerActor
onready var king : KingActor = KING_SCENE.instance() as KingActor
onready var transition_anim : AnimationPlayer = $TransitionLayer/AnimationPlayer

func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			exiting = true
			
func createTextbox(line := "", nameplate := "", portrait : Texture = null, soundTable := [], pitchRange := Vector2.ONE, soundMode := 1) -> TextBox:
	if exiting: return null
	
	if textbox: 
		textbox.destroy()
		return null
	
	if !line: return null
	
	textbox = TB_SCENE.instance()
	
	textbox.line = line
	
	add_child(textbox)
	
	textbox.nameplate.text = nameplate
	textbox.portrait.texture = portrait
	textbox.voice.soundTable = soundTable
	textbox.voice.pitchRange = pitchRange
	textbox.voice.soundMode = soundMode
	
	textbox.refresh()
	
	return textbox
	
func spawn_player(where := get_tree().current_scene, position := Vector2.ZERO):
	where.add_child(player)
	player.global_position = position
	
func spawn_king(where := get_tree().current_scene, position := Vector2.ZERO):
	where.add_child(king)
	king.global_position = position
	
func change_scene(next : PackedScene):
	if transitioning:
		return
	
	transition_anim.play("in")
	transitioning = true
	
	yield(transition_anim, "animation_finished")
	
	get_tree().change_scene_to(next)
	
	transitioning = false
	transition_anim.play("out")
