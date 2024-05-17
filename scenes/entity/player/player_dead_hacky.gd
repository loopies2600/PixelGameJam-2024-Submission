extends Node

var active := false

onready var player : PlayerActor = get_parent()

func _process(delta):
	if not active: return
	
	player.extra_anim.play("Dead")
	
	var master_bus_vol := AudioServer.get_bus_volume_db(0)
	
	var next_vol : float = lerp(master_bus_vol, -80.0, 0.2 * delta)
	
	AudioServer.set_bus_volume_db(0, next_vol)
	
