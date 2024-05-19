extends Node2D

const CUTSCENE_1 := preload("res://scenes/cutscene/cutscene_1.tscn")

onready var pany_label : Label = $PanyKey
onready var base_anim : AnimationPlayer = $AnimationPlayer
onready var base_cam : Camera2D = $Camera2D

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			_on_key_press()
	
func _on_key_press():
	Global.change_scene(CUTSCENE_1)
	
	return
	
	if pany_label.visible:
		Global.change_scene(CUTSCENE_1)
	
