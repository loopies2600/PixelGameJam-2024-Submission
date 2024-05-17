extends KinematicActor

export (float) var attack_cooldown := 0.5

enum States {
	IDLE,
	PATROL_CALM,
	PATROL_ANGRY,
	CHASE,
	DASH,
	RETALIATE
}

var current_state : int = States.IDLE

var patrol_direction : Vector2 = Vector2.RIGHT

onready var patrol_turn_timer : Timer = $PatrolTurnTimer
onready var anim_sprite : AnimatedSprite = $MainSprite
onready var extra_anim : AnimationPlayer = $AnimationPlayer
onready var pinch_sound : AudioStreamPlayer = $PinchSound
onready var attack_timer : Timer = $AttackTimer

var dash_elapsed := 0.0
var vel_inverted := false

func _ready():
	_patrol_change_direction()
	elapsed_alive += rand_range(0.0, 4.0)
	
	patrol_turn_timer.connect("timeout", self, "_patrol_change_direction")
	attack_timer.connect("timeout", self, "_on_attack_timer_timeout")
	
	Global.player.connect("attacked", self, "_on_player_attack")
	
func _on_player_attack(victim, damage_amount):
	if victim.global_position.distance_squared_to(global_position) <= pow(tracking_distance, 2.0):
		current_state = States.RETALIATE
	
func _patrol_change_direction():
	randomize()
	
	var random_angle := rand_range(0.0, TAU)
	
	patrol_direction = Vector2.RIGHT.rotated(random_angle)
	
func _on_attack_timer_timeout():
	if current_state != States.DASH:
		return
	
	attacking = false
	
	if can_attack(Global.player):
		attack(Global.player)
	
	attacking = true
	
func _on_successful_punch(target : KinematicActor):
	pinch_sound.play()
	
	if target.invencible: return
	
	dash_elapsed = 0.0
	
	._on_successful_punch(target)
	
func _physics_process(delta):
	match current_state:
		States.IDLE:
			rotation = 0.0
			velocity.y = sin(elapsed_alive) * 8.0
			
			if find_player() && not Global.player.dead:
				current_state = States.CHASE
		States.PATROL_CALM:
			velocity = velocity.linear_interpolate(patrol_direction * base_speed, 1.0 - steering)
			
			velocity += Vector2(0.0, sin(elapsed_alive) * 8.0).rotated(velocity.angle())
			
			if find_player() && not Global.player.dead:
				current_state = States.CHASE
		States.PATROL_ANGRY:
			velocity = velocity.linear_interpolate(patrol_direction * (base_speed * 3.0), 1.0 - steering)
	
			rotation = velocity.angle()
			
			if find_player() && not Global.player.dead:
				current_state = States.CHASE
		States.CHASE:
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos : Vector2 = Global.player.global_position
			
			var angle_to_player := global_position.angle_to_point(target_pos)
			
			velocity = Vector2.LEFT.rotated(angle_to_player) * (base_speed * 3.0)
			
			if Global.player.dead:
				current_state = States.PATROL_CALM
			
			if can_attack(Global.player):
				current_state = States.DASH
		States.DASH:
			if Global.player.dead:
				current_state = States.PATROL_CALM
				
			if attack_timer.is_stopped():
				attack_timer.start()
				
			if not can_attack(Global.player):
				anim_sprite.animation = "default"
				current_state = States.CHASE
				return
			
			if attack_timer.time_left <= attack_timer.wait_time / 2.0:
				anim_sprite.animation = "dash"
			else:
				anim_sprite.animation = "default"
			
			dash_elapsed += delta
			
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos : Vector2 = Global.player.global_position
			
			var angle_to_player := global_position.angle_to_point(target_pos)
			
			velocity += Vector2.LEFT.rotated(angle_to_player) * (base_speed * dash_elapsed)
		States.RETALIATE:
			if Global.player.dead:
				current_state = States.PATROL_ANGRY
			
			anim_sprite.animation = "default"
			
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos : Vector2 = Global.player.global_position
			
			var angle_to_player := global_position.angle_to_point(target_pos)
			
			velocity = Vector2.RIGHT.rotated(angle_to_player) * (base_speed * 4.0)
	
	rotation = velocity.angle()
