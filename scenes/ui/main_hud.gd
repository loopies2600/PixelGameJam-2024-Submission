extends CanvasLayer

onready var player_health_progress : TextureProgress = $QuexoteHealthbar/HealthProgress

func _process(delta):
	_update_health_progress()
	
func _update_health_progress():
	if Global.player == null:
		return
	
	player_health_progress.max_value = Global.player.max_health
	player_health_progress.value = Global.player.health
