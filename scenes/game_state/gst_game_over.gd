extends Node2D

const GAME_STATE := preload("res://scenes/game_state/gst_gamefield.tscn")
const MAIN_MENU := preload("res://scenes/game_state/gst_main_menu.tscn")

export (Color) var decision_color = Color.yellow

var selected := 0
var decision_made := false

onready var decisions := [$DeadLayer/Decisions/Accept, $DeadLayer/Decisions/Cancel]
onready var scroll_sound : AudioStreamPlayer = $ScrollSound
onready var pick_sound : AudioStreamPlayer = $PickSound
onready var anim : AnimationPlayer = $AnimationPlayer
onready var quejonted : AnimatedSprite = $DeadLayer/PlayerDummy
onready var screen_tex_rect : TextureRect = $ScreenCopy

var dead_scale := Vector2.ONE

func _ready():
	AudioServer.set_bus_volume_db(0, 0.0)
	
	screen_tex_rect.texture = Global.screen_texture
	
	if Global.persistent_data.get("player_facing"):
		dead_scale = Global.persistent_data.get("player_facing")
	
	quejonted.scale = dead_scale
	
	update_decision()
	
func _input(event):
	if event.is_action_pressed("move_right"):
		selected = wrapi(selected + 1, 0, 2)
		scroll_sound.play()
	
	if event.is_action_pressed("move_left"):
		selected = wrapi(selected - 1, 0, 2)
		scroll_sound.play()
	
	if event.is_action_pressed("attack") or event.is_action_pressed("interact"):
		make_decision()
	
	update_decision()
	
func make_decision():
	if decision_made:
		return
	
	pick_sound.play()
	anim.play("HideText")
	
	decision_made = true
	
	match selected:
		0:
			yield(quejonte_escape_screen(), "completed")
			
			Global.change_scene(GAME_STATE)
		1:
			Global.reset_game_state()
			Global.change_scene(MAIN_MENU)
	
func quejonte_escape_screen():
	yield(get_tree().create_timer(1.0), "timeout")
	
	quejonted.play("idle_h")
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	quejonted.play("attack1_h")
	quejonted.get_child(0).play()
	
	yield(quejonted, "animation_finished")
	quejonted.play("idle_h")
	
	yield(get_tree().create_timer(0.1), "timeout")
	
	quejonted.play("attack1_h")
	quejonted.get_child(0).play()
	
	yield(quejonted, "animation_finished")
	quejonted.play("idle_h")
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	quejonted.play("idle_h")
	
	yield(get_tree().create_timer(1.5), "timeout")
	
	quejonted.play("walk_h")
	
	yield(get_tree().create_timer(1.5), "timeout")
	
func _process(delta):
	if quejonted.animation == "walk_h":
		quejonted.position.x += delta * (86.0 * dead_scale.x)
		
func update_decision():
	for i in range(decisions.size()):
		var label : Label = decisions[i]
		
		label.modulate = Color.white
	
	decisions[selected].modulate = decision_color
