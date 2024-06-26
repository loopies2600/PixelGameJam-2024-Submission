extends Sprite

const FISHES_SHEET := preload("res://assets/sprites/hud/fishometer_fishes.png")
const FISH_DIMENSIONS := Vector2(26, 11)
const STACK_COUNT := 2
const MAX_FISHES := 200

var fish_positions := PoolVector2Array()
var fish_regions := []

var addition_stack := 0
var subtraction_stack := 0

onready var fish_count : Label = $FishCount
onready var anim : AnimationPlayer = $AnimationPlayer

func _ready():
	yield(owner, "ready")
	
	if Global.player:
		Global.player.inventory.connect("item_added", self, "_on_inventory_item_added")
		Global.player.inventory.connect("item_deleted", self, "_on_inventory_item_deleted")
	
func _on_inventory_item_added(new_item_id : int):
	if not Global.king.active:
		if Global.player.inventory.get_item_count() >= MAX_FISHES:
			$FullStackJingle.play()
			anim.play("GoOffscreen")
			Global.player.inventory.locked = true
			return
		
	addition_stack += 1
	
	if addition_stack != STACK_COUNT:
		return
	
	addition_stack = 0
	
	var fish_region_idx := new_item_id
	var source_rect := Rect2(Vector2(FISH_DIMENSIONS.x * fish_region_idx, 0.0), FISH_DIMENSIONS)
	
	var random_x_pos := rand_range(-24, -4)
	var y_elevation := 0.0
	
	for i in range(fish_positions.size()):
		if i % 2 == 0:
			y_elevation += rand_range(2, 6)
	
	fish_regions.append(source_rect)
	fish_positions.append(Vector2(random_x_pos, -20 - y_elevation))
	
func fish_under_consent_of_king():
	var fish_count := 0
	
	if is_instance_valid(Global.player):
		fish_count = Global.player.inventory.get_item_count()
		Global.player.health = Global.player.max_health
		
	var king_timer : Timer = get_tree().current_scene.king_timer
	
	king_timer.start()
	
	Global.king.fish_count += fish_count
	
func _wipe_inventory():
	Global.player.inventory.locked = false
	
	fish_regions.clear()
	fish_positions.clear()
	
	addition_stack = 0
	subtraction_stack = 0
	
	Global.player.inventory.wipe()
	
func _on_inventory_item_deleted(item_id):
	subtraction_stack += 1
	
	if subtraction_stack != STACK_COUNT:
		return
	
	subtraction_stack = 0
	
	if not fish_regions.empty():
		fish_regions.pop_back()
		
	if not fish_positions.empty():
		fish_positions.remove(-1)
	
func _process(_delta):
	update()
	
	fish_count.text = str(Global.player.inventory.get_item_count())
	
func _draw():
	if not is_instance_valid(Global.player):
		return
	
	for i in range(fish_regions.size()):
		var destination_rect := Rect2(fish_positions[i], FISH_DIMENSIONS)
		
		draw_texture_rect_region(FISHES_SHEET, destination_rect, fish_regions[i])
	
	draw_texture(texture, Vector2(-24, -13))
