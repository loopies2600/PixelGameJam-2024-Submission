extends Node2D

var cutscene_running := false

onready var music : AudioStreamPlayer = $BGMusic

func _ready():
	if Global.level_cutscene_seen(0):
		CutsceneManager.emit_signal("cutscene_ended")
		
		_on_cutscene_end()
		return
	
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
	
	music.stream = Global.LEVEL_MUSIC[Global.level_id]
	
	if not music.playing:
		music.play()
	
	Global.saw_initial_cutscene[Global.level_id] = true
