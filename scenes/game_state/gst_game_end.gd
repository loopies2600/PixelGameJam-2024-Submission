extends Node2D

onready var screen_tex_rect : TextureRect = $ScreenCopy

func _ready():
	screen_tex_rect.texture = Global.screen_texture
