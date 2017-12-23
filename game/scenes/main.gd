extends Node2D
var grid

func _ready():
	grid = get_node("grid")

func bullet_hit(pos, direction):
	var shift = Vector2(0.5,0)
	if !abs(direction.y):
		shift = Vector2(0,0.5)
	var cells_pos = [grid.world_to_map(pos + 9 * (direction + shift)), grid.world_to_map(pos + 9 * (direction - shift))]
	var cells_id = [grid.get_cell(cells_pos[0].x,cells_pos[0].y), grid.get_cell(cells_pos[1].x,cells_pos[1].y)]

	for i in range(2):
		if cells_id[i] == 0:
			grid.set_cell(cells_pos[i].x,cells_pos[i].y,3)
		elif cells_id[i] == 3:
			grid.set_cell(cells_pos[i].x,cells_pos[i].y,-1)
#	
	get_node("hit_sound").play("hit")