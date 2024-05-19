extends KinematicActor

onready var anim : AnimationPlayer = $AnimationPlayer

func _explode():
	var explosion = EXPLOSION_EFFECT.instance()
	
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
func _on_damage_taken(damage_amount : int, source : Node):
	anim.stop()
	anim.play("TakeDamage")
	
func _on_death(damage_amount : int, source : Node):
	_explode()
	queue_free()
