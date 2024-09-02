extends Node2D

export var radius : float = 16.0
export var duration : float = 0.3

var ignore_mouse := false

var elapsed := 0.0

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && !event.pressed:
			ignore_mouse = true
	
func _physics_process(delta):
	global_position = get_global_mouse_position()
	
func _process(delta):
	elapsed += delta
	
	var hover : bool = elapsed >= duration / 2.0 && Input.is_mouse_button_pressed(BUTTON_LEFT) && !ignore_mouse
	if hover:
		elapsed = duration / 2.0
		return
		
	if elapsed >= duration:
		queue_free()
		return
	
	update()
	
func _draw():
	var size : float = lerp(0.0, radius, elapsed / duration)
	var alpha : float = lerp(1.0, 0.0, elapsed / duration)
	
	var color := Color.papayawhip
	color.a = alpha
	
	var colorb := Color.aqua
	colorb.a = alpha
	
	draw_circle(Vector2.ZERO, size * 1.1, colorb)
	draw_circle(Vector2.ZERO, size, color)
	draw_circle(Vector2.ZERO, size / 2.0, color)
