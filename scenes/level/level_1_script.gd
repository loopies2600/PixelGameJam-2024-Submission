extends Node2D

var cutscene_running := false

onready var music : AudioStreamPlayer = $BGMusic

func _ready():
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is Cutscene:
			if cutscene_running: return
			
			child.cam = Global.player.cam
			
			child.execute()
			CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
			
			cutscene_running = true

func _on_cutscene_end():
	get_parent().on_level_initial_cutscene_end()
	$BGMusic.play()
