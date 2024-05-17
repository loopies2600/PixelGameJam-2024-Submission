extends Node2D

const LEVELS := [
	preload("res://scenes/level/level_1.tscn")
]

const HUD := preload("res://scenes/ui/main_hud.tscn")

export (int) var lv_id := 0

onready var level : Node = LEVELS[lv_id].instance()
onready var main_hud := HUD.instance()

onready var king_timer : Timer = $KingTimer

func _ready():
	Global.spawn_player(self, Global.player_spawn_pos)
	
	add_child(level)
	
	add_child(main_hud)
	main_hud.owner = self
	main_hud.hide()
	
	king_timer.connect("timeout", self, "_on_king_timer_timeout")
	
func on_level_initial_cutscene_end():
	main_hud.show()
	king_timer.start()
	
func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_F4:
			get_tree().reload_current_scene()
	
func _on_king_timer_timeout():
	Global.spawn_king(self, Global.player.global_position - Vector2(0.0, 256.0))
