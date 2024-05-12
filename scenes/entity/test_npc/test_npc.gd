extends KinematicActor

func _on_damage_taken(damage_amount, source):
	$AnimationPlayer.play("TakeDamage")
