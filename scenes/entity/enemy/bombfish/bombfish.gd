extends PufferfishActor

onready var emitter := $bullet_emitter

func _pre_inflation():
	_explode()
	
func _explode():
	var explosion = EXPLOSION_EFFECT.instance()
	
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	
	remove_child(emitter)
	
	get_parent().add_child(emitter)
	emitter.global_position = global_position
	
	emitter.fire()
	
	Global.player.attack(self, 9999)

func _tick_baf(delta : float):
	anim_sprite.animation = "idle"
	
	velocity = (Vector2.RIGHT.rotated(deg2rad(base_angle)) * base_speed) * dir
	
	if find_player():
		current_state = States.INFLATE
	
	if _find_wall():
		dir = -dir
		
func _tick_inflate(delta : float):
	if Global.player.dead:
		current_state = States.BACK_AND_FORTH
	
	if extra_anim.current_animation != "Inflate":
		_pre_inflation()
		extra_anim.play("Inflate")
	
	velocity *= 0.9
	
	anim_sprite.animation = "inflate"
	
	yield(extra_anim, "animation_finished")
	
	_post_inflation()
	current_state = States.BACK_AND_FORTH
