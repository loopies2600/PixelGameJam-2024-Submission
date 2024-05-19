extends StaticBody2D

export (float) var cooldown := 1.0

var open := false setget _set_open

onready var visibility : VisibilityNotifier2D = $VisibilityNotifier2D

onready var anim_sprite : AnimatedSprite = $MainSprite
onready var cooldown_timer : Timer = $Cooldown
onready var emitter := $bullet_emitter

func _ready():
	visibility.connect("screen_entered", self, "_on_screen_entered")
	visibility.connect("screen_exited", self, "_on_screen_exited")
	
	cooldown_timer.connect("timeout", self, "_on_cooldown_done")
	
	CutsceneManager.connect("cutscene_ended", self, "_on_screen_entered")
	CutsceneManager.connect("cutscene_started", self, "_on_screen_exited")
	
func _on_screen_entered():
	self.open = true
	
func _on_screen_exited():
	self.open = false
	
func _process(delta : float):
	z_index = int(clamp(get_global_transform_with_canvas().origin.y, 0, VisualServer.CANVAS_ITEM_Z_MAX))
	
	if open:
		self.open = not CutsceneManager.running
	
func _on_cooldown_done():
	if not open:
		return
	
	emitter.fire()
	
func _set_open(value : bool):
	if value == open:
		return
	
	open = value
	
	if open:
		cooldown_timer.wait_time = cooldown
		cooldown_timer.start()
		
		anim_sprite.play("opening")
		
		yield(anim_sprite, "animation_finished")
		
		anim_sprite.play("open")
	else:
		anim_sprite.play("opening")
		
		yield(anim_sprite, "animation_finished")
		
		anim_sprite.play("closed")
