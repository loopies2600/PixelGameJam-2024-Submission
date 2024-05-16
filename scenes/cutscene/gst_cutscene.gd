extends Node2D

const GAME_STATE := preload("res://scenes/game_state/gst_gamefield.tscn")

var cutscene_running := false

func _ready():
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is Cutscene:
			if cutscene_running: return
			
			child.cam = $BaseCam
			
			child.execute()
			CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
			
			cutscene_running = true

func _on_cutscene_end():
	get_tree().change_scene_to(GAME_STATE)
