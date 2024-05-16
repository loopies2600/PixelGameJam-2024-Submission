extends Node2D

const LEVELS := [
	preload("res://scenes/level/level_1.tscn")
]

const HUD := preload("res://scenes/ui/main_hud.tscn")

export (int) var lv_id := 0

onready var level : Node = LEVELS[lv_id].instance()
onready var main_hud := HUD.instance()

func _ready():
	add_child(level)
	Global.spawn_player()
	
	add_child(main_hud)
	main_hud.owner = self
	
