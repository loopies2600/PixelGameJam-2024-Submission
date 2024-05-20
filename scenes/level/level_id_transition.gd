extends Area2D

export (int) var new_level_id := 1

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func _play_cutscene():
	for i in range(get_child_count()):
		var child = get_child(i)
		
		if child is Cutscene:
			child.cam = Global.player.cam
			
			child.execute()
			CutsceneManager.connect("cutscene_ended", self, "_on_cutscene_end")
			
func _on_body_entered(body):
	if body.name == Global.player.name:
		if Global.level_id == new_level_id:
			return
		
		var level = get_tree().current_scene.level
		
		_play_cutscene()
		
		Global.level_id = new_level_id
		Global.spawn_pos_override = Vector2.ZERO
		
		var tween_volume := create_tween()
		
		tween_volume.tween_property(level.music, "volume_db", -60.0, 5.0)
		
		yield(tween_volume, "finished")
		
		level.music.volume_db = 0.0
		
		level._on_cutscene_end()
