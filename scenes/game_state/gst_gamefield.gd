extends Node2D

const KING_DARKNESS := "#745f89"

const LEVELS := [
	preload("res://scenes/level/level_1.tscn")
]

const HUD := preload("res://scenes/ui/main_hud.tscn")
const CLICK_BUBBLE := preload("res://scenes/ui/click_bubble.tscn")

onready var level : Node = LEVELS[0].instance()
onready var main_hud := HUD.instance()

onready var king_timer : Timer = $KingTimer
onready var king_music : AudioStreamPlayer = $KingMusic
onready var game_modulate : CanvasModulate = $GameModulate

onready var base_canvas_modulate := game_modulate.color

func _ready():
	Global.spawn_player(self, Global.get_player_spawn_pos())
	
	add_child(level)
	
	add_child(main_hud)
	main_hud.owner = self
	
	king_timer.connect("timeout", self, "_on_king_timer_timeout")
	
func on_level_initial_cutscene_end():
	main_hud.show()
	
	if king_timer.is_stopped():
		king_timer.start()
	
func _on_king_timer_timeout():
	main_hud.show_king_is_here()
	
	Global.spawn_king(self, Global.player.global_position - Vector2(0.0, 512.0))
	
	Global.king.active = true
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	king_music.play()
	
func _input(event):
	if CutsceneManager.running:
		return
	
	if event is InputEventMouseButton:
		var base_click : bool = event.button_index == BUTTON_LEFT && event.pressed
		
		if base_click:
			var clk := CLICK_BUBBLE.instance()
			
			get_tree().root.add_child(clk)
			
			clk.global_position = get_global_mouse_position()
	
func _process(delta):
	if not is_instance_valid(Global.king):
		return
		
	if Global.king.active:
		game_modulate.color = game_modulate.color.linear_interpolate(Color(KING_DARKNESS), 0.4 * delta)
		
		king_music.volume_db = lerp(king_music.volume_db, 0.0, 0.1 * delta)
		level.music.volume_db = lerp(level.music.volume_db, -80.0, 0.05 * delta)
