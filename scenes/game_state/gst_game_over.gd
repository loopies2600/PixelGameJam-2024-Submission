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

func _ready():
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
			Global.level_id = 0
			Global.player_spawn_pos = Vector2(128, 128)
			Global.change_scene(MAIN_MENU)
	
func quejonte_escape_screen():
	yield(get_tree().create_timer(1.0), "timeout")
	
	quejonted.play("idle_h")
	
	yield(get_tree().create_timer(2.0), "timeout")
	
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
	
	yield(get_tree().create_timer(3.0), "timeout")
	
func _process(delta):
	if quejonted.animation == "walk_h":
		quejonted.position.x += delta * 86.0
		
func update_decision():
	for i in range(decisions.size()):
		var label : Label = decisions[i]
		
		label.modulate = Color.white
	
	decisions[selected].modulate = decision_color
