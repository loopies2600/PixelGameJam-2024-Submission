extends Node2D

var boss_actor : KinematicActor = null

onready var progress_bar : TextureProgress = $ProgressBar

func _process(delta):
	visible = is_instance_valid(boss_actor)
	
	if is_instance_valid(boss_actor):
		update_bar(delta)
	
func update_bar(delta : float):
	progress_bar.max_value = boss_actor.max_health
	progress_bar.value = boss_actor.health
