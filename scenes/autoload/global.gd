extends Node

const TB_SCENE := preload("res://scenes/screenplayer/text_box/TextBox.tscn")
const MAINFONT := preload("res://assets/screenplayer/fonts/aquarius_monospace.tres")
const PLAYER_SCENE := preload("res://scenes/entity/player/player.tscn")
const KING_SCENE := preload("res://scenes/entity/god_himself/KING.tscn")

const LEVEL_MUSIC := [
	preload("res://assets/streams/music/level1.mp3"),
	preload("res://assets/streams/music/level2.mp3"),
	preload("res://assets/streams/music/king_theme.mp3"),
	preload("res://assets/streams/music/Nivel_3.mp3"),
	preload("res://assets/streams/music/Boss_Fight.mp3")
]

const LEVEL_SPAWN_POSITIONS := [
	Vector2(128, 128),
	Vector2(2632, 634),
	Vector2(5350, 700),
	Vector2(5840, -810)
]

var textbox : TextBox
var _tbBgOffset : Vector2 = Vector2.ZERO
var focusActor : Node2D = null

var exiting : bool = false
var transitioning : bool = false

var level_id := 0
var saw_initial_cutscene := [false, true, true, false]

var player_spawn_pos : Vector2 = LEVEL_SPAWN_POSITIONS[level_id]
var spawn_pos_override : Vector2 = Vector2.ZERO
#var player_spawn_pos := Vector2(128, 128)
var persistent_data := {}
var screen_texture : ImageTexture

onready var player : PlayerActor = PLAYER_SCENE.instance() as PlayerActor
onready var king : KingActor = KING_SCENE.instance() as KingActor
onready var transition_anim : AnimationPlayer = $TransitionLayer/AnimationPlayer

func _unhandled_input(event):
	if event.is_action_pressed("fullscreen"):
		OS.window_fullscreen = not OS.window_fullscreen
		
func _notification(what):
	match what:
		NOTIFICATION_WM_QUIT_REQUEST:
			exiting = true
	
func reset_game_state():
	king = KING_SCENE.instance() as KingActor
	player = PLAYER_SCENE.instance() as PlayerActor
	
	level_id = 0
	player_spawn_pos = LEVEL_SPAWN_POSITIONS[level_id]
	spawn_pos_override = Vector2.ZERO
	persistent_data = {}
	saw_initial_cutscene = [false, true, true, false]
	
func get_player_spawn_pos() -> Vector2:
	var spawn_pos : Vector2 = LEVEL_SPAWN_POSITIONS[level_id]
	
	if spawn_pos_override != Vector2.ZERO:
		spawn_pos = spawn_pos_override
		
	return spawn_pos
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
	player = PLAYER_SCENE.instance() as PlayerActor
	
	where.add_child(player)
	player.global_position = position
	
func spawn_king(where := get_tree().current_scene, position := Vector2.ZERO):
	king = KING_SCENE.instance() as KingActor
	
	where.add_child(king)
	king.global_position = position
	
func play_sound(sound_path := ""):
	if sound_path.empty():
		return
	
	var audio_stream := AudioStreamPlayer.new()
	
	audio_stream.stream = load(sound_path)
	
	add_child(audio_stream)
	
	audio_stream.play()
	audio_stream.bus = "Sound"
	
	yield(audio_stream, "finished")
	
	audio_stream.queue_free()
	
func level_cutscene_seen(which := level_id) -> bool:
	return saw_initial_cutscene[which]
	
func save_screen():
	var main_viewport_texture := get_viewport().get_texture()
	
	var image := main_viewport_texture.get_data()
	image.flip_y()
	
	var image_texture := ImageTexture.new()
	
	image_texture.create_from_image(image)
	
	screen_texture = image_texture
	
func _chscn_transition(next : PackedScene):
	transition_anim.play("in")
	transitioning = true
	
	yield(transition_anim, "animation_finished")
	
	get_tree().change_scene_to(next)
	
	transitioning = false
	transition_anim.play("out")
	
func _chscn_raw(next : PackedScene):
	get_tree().change_scene_to(next)
	
func change_scene(next : PackedScene, smooth := true, persist := {}):
	if transitioning:
		return
	
	save_screen()
	persistent_data = persist
	
	if smooth:
		_chscn_transition(next)
	else:
		_chscn_raw(next)
