extends KinematicActor

export (float) var attack_cooldown := 0.5

enum States {
	IDLE,
	PATROL_CALM,
	PATROL_ANGRY,
	CHASE,
	DASH
}

var current_state : int = States.IDLE

var patrol_direction : Vector2 = Vector2.RIGHT

onready var patrol_turn_timer : Timer = $PatrolTurnTimer
onready var anim_sprite : AnimatedSprite = $MainSprite
onready var extra_anim : AnimationPlayer = $AnimationPlayer
onready var pinch_sound : AudioStreamPlayer = $PinchSound

var dash_elapsed := 0.0

func _ready():
	_patrol_change_direction()
	elapsed_alive += rand_range(0.0, 4.0)
	
	patrol_turn_timer.connect("timeout", self, "_patrol_change_direction")
	
func _patrol_change_direction():
	randomize()
	
	var random_angle := rand_range(0.0, TAU)
	
	patrol_direction = Vector2.RIGHT.rotated(random_angle)
	
func _on_successful_punch(target : KinematicActor):
	._on_successful_punch(target)
	pinch_sound.play()
	
func _physics_process(delta):
	match current_state:
		States.IDLE:
			rotation = 0.0
			velocity.y = sin(elapsed_alive) * 8.0
			
			if find_player():
				current_state = States.CHASE
		States.PATROL_CALM:
			velocity = velocity.linear_interpolate(patrol_direction * base_speed, 1.0 - steering)
			
			velocity += Vector2(0.0, sin(elapsed_alive) * 8.0).rotated(velocity.angle())
			
			if find_player():
				current_state = States.CHASE
		States.PATROL_ANGRY:
			velocity = velocity.linear_interpolate(patrol_direction * (base_speed * 3.0), 1.0 - steering)
	
			rotation = velocity.angle()
			
			if find_player():
				current_state = States.CHASE
		States.CHASE:
			var distance_to_player := global_position.distance_squared_to(Global.player.global_position)
			
			var target_pos : Vector2 = Global.player.global_position
			
			var angle_to_player := global_position.angle_to_point(target_pos)
			
			velocity = Vector2.LEFT.rotated(angle_to_player) * (base_speed * 3.0)
			
			if distance_to_player < pow(attack_distance, 2.0):
				current_state = States.DASH
		States.DASH:
			var player_nearby := global_position.distance_squared_to(Global.player.global_position) <= pow(attack_distance, 2.0)
			
			if not player_nearby:
				dash_elapsed = 0.0
				anim_sprite.animation = "default"
				current_state = States.CHASE
				
			if not find_player():
				dash_elapsed = 0.0
				anim_sprite.animation = "default"
				current_state = States.PATROL_CALM
			
			velocity *= 0.9
			
			dash_elapsed += delta
			
			if dash_elapsed >= attack_cooldown:
				extra_anim.play("Dash")
				anim_sprite.animation = "dash"
				
				attack(Global.player)
				attacking = true
			if dash_elapsed >= attack_cooldown * 2.0:
				anim_sprite.animation = "default"
				
				dash_elapsed = 0.0
				attacking = false
