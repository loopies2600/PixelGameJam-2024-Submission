extends Area2D

onready var lv2_bg : TextureRect = $"../ParallaxBackground/ParallaxLayer/level2bg"
onready var lv3_bg : TextureRect = $"../ParallaxBackground/ParallaxLayer/level3bg"

func _ready():
	connect("body_entered", self, "_on_body_enter")
	
func _on_body_enter(body):
	if body.name == Global.player.name:
		if not lv3_bg.visible:
			lv2_bg.hide()
			lv3_bg.show()
		else:
			lv2_bg.show()
			lv3_bg.hide()
