extends Sprite

const FISHES_SHEET := preload("res://assets/sprites/hud/fishometer_fishes.png")
const FISH_DIMENSIONS := Vector2(26, 11)

var fish_positions := PoolVector2Array()
var fish_regions := []

func _ready():
	if Global.player:
		Global.player.inventory.connect("item_added", self, "_on_inventory_item_added")
	
func _on_inventory_item_added(new_item_id : int):
	var fish_region_idx := new_item_id
	var source_rect := Rect2(Vector2(FISH_DIMENSIONS.x * fish_region_idx, 0.0), FISH_DIMENSIONS)
	
	var random_x_pos := rand_range(-24, -4)
	var y_elevation := 0.0
	
	for i in range(fish_positions.size()):
		if i % 2 == 0:
			y_elevation += rand_range(2, 6)
	
	fish_regions.append(source_rect)
	fish_positions.append(Vector2(random_x_pos, -20 - y_elevation))
	
func _on_inventory_item_deleted(item_id):
	fish_regions.pop_back()
	fish_positions.remove(-1)
	
func _process(_delta):
	update()
	
func _draw():
	if Global.player == null:
		return
	
	for i in range(fish_regions.size()):
		var destination_rect := Rect2(fish_positions[i], FISH_DIMENSIONS)
		
		draw_texture_rect_region(FISHES_SHEET, destination_rect, fish_regions[i])
	
	draw_texture(texture, Vector2(-24, -13))
