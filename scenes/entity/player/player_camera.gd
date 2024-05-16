extends Camera2D

var shake_intensity := 0.0

var elapsed := 0.0

func _process(delta):
	elapsed += delta
	
	shake_intensity -= elapsed
	shake_intensity = max(0.0, shake_intensity)
	
	if not is_equal_approx(shake_intensity, 0.0):
		offset.x = rand_range(-shake_intensity, shake_intensity)
		offset.y = rand_range(-shake_intensity, shake_intensity)
	
func shake(intensity := 0.0):
	elapsed = 0.0
	shake_intensity = intensity
