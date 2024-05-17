extends Node2D

const KING_DARKNESS := "#745f89"

const LEVELS := [
	preload("res://scenes/level/level_1.tscn")
]

const HUD := preload("res://scenes/ui/main_hud.tscn")

export (int) var lv_id := 0

onready var level : Node = LEVELS[lv_id].instance()
onready var main_hud := HUD.instance()

onready var king_timer : Timer = $KingTimer
onready var king_music : AudioStreamPlayer = $KingMusic
onready var game_modulate : CanvasModulate = $GameModulate

onready var base_canvas_modulate := game_modulate.color

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
	Global.spawn_king(self, Global.player.global_position - Vector2(0.0, 1024.0))
	
	Global.king.active = true
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	king_music.play()
	
func _process(delta):
	if Global.king.active:
		game_modulate.color = game_modulate.color.linear_interpolate(Color(KING_DARKNESS), 0.4 * delta)
		
		king_music.volume_db = lerp(king_music.volume_db, 0.0, 0.1 * delta)
		level.music.volume_db = lerp(level.music.volume_db, -80.0, 0.05 * delta)
	else:
		game_modulate.color = game_modulate.color.linear_interpolate(base_canvas_modulate, 1.0 * delta)
		
		king_music.volume_db = lerp(king_music.volume_db, -80.0, 0.1 * delta)
		level.music.volume_db = lerp(level.music.volume_db, 0.0, 0.05 * delta)
