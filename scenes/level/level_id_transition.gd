extends Area2D

export (int) var new_level_id := 1

var crossed := false

func _ready():
	connect("body_entered", self, "_on_body_entered")
	
func _on_body_entered(body):
	if crossed:
		return
	
	if body.name == Global.player.name:
		var level = get_tree().current_scene.level
		
		crossed = true
		Global.level_id = new_level_id
		
		var tween_volume := create_tween()
		
		tween_volume.tween_property(level.music, "volume_db", -60.0, 5.0)
		
		yield(tween_volume, "finished")
		
		level.music.volume_db = 0.0
		level._on_cutscene_end()
