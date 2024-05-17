extends Node2D

const CUTSCENE_1 := preload("res://scenes/cutscene/cutscene_1.tscn")

onready var pany_label : Label = $PanyKey
onready var cfg_layer : CanvasLayer = $ConfigLayer
onready var base_anim : AnimationPlayer = $AnimationPlayer
onready var base_cam : Camera2D = $Camera2D

onready var music_slider : HSlider = $ConfigLayer/ColorRect/VolumeControl/HSlider
onready var sound_slider : HSlider = $ConfigLayer/ColorRect/VolumeControl/HSlider2

func _ready():
	cfg_layer.hide()
	
	music_slider.connect("value_changed", self, "_on_music_volume_slide")
	sound_slider.connect("value_changed", self, "_on_sound_volume_slide")
	
func _on_music_volume_slide(value):
	var volume_db := range_lerp(value, 0, 100, -80, 0)
	
	AudioServer.set_bus_volume_db(2, volume_db)
	
func _on_sound_volume_slide(value):
	var volume_db := range_lerp(value, 0, 100, -80, -8)
	
	AudioServer.set_bus_volume_db(1, volume_db)
	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed:
			_on_key_press()
	
func _on_key_press():
	if not cfg_layer.visible:
		_show_config_submenu()
	else:
		Global.change_scene(CUTSCENE_1)
	
func _show_config_submenu():
	cfg_layer.show()
	
	base_anim.stop()
	base_anim.play("ShowConfig")
	
