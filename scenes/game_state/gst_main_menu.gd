extends Node2D

const CUTSCENE_1 := preload("res://scenes/cutscene/cutscene_1.tscn")

onready var pany_label : Label = $PanyKey

func _input(event):
	if event is InputEventKey:
		Global.change_scene(CUTSCENE_1)
		
		if pany_label.visible:
			Global.change_scene(CUTSCENE_1)
