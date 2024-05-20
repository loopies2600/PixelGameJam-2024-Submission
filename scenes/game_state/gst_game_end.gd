extends Node2D

onready var screen_tex_rect : TextureRect = $ScreenCopy

onready var MAIN_MENU := load("res://scenes/game_state/gst_main_menu.tscn")

var cutscene_running := false

func _ready():
	Global.player = Global.PLAYER_SCENE.instance()
	
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is Cutscene:
			if cutscene_running: return
			
			child.cam = $BaseCam
			
			child.execute()
			CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
			
			cutscene_running = true

func _on_cutscene_end():
	AudioServer.set_bus_mute(1, false)
	Global.reset_game_state()
	Global.change_scene(MAIN_MENU)
