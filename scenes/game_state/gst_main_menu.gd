extends Node2D

const GAME_STATE := preload("res://scenes/game_state/gst_gamefield.tscn")

onready var pany_label : Label = $PanyKey

func _input(event):
	if event is InputEventKey:
		get_tree().change_scene_to(GAME_STATE)
		
		if pany_label.visible:
			get_tree().change_scene_to(GAME_STATE)
