extends Node2D
var grid
var cell_size = 36
var explosionObj = load("res://objects/explosion.tscn")
const world_size = 25
var world = []

func _ready():
	grid = get_node("grid")
	for x in range(world_size):
		world.append([])
		for y in range(world_size):
			world[x].append(null)

func is_cell_vacant(pos, direction):
	var grid_pos = world_to_map(pos) + direction
	if world[grid_pos.x][grid_pos.y] == null:
		return true
	else:
		return false

func update_tank_pos(tank):
	var grid_pos = world_to_map(tank.get_pos())
	world[grid_pos.x][grid_pos.y] = null
	
	var new_grid_pos = grid_pos + tank.direction
	world[new_grid_pos.x][new_grid_pos.y] = tank
	var target_pos = map_to_world(new_grid_pos) 
	return target_pos


func world_to_map(pos):
	var cell = Vector2(int(pos.x / cell_size), int(pos.y / cell_size))
	return cell
	
func map_to_world(cell):
	var pos = Vector2(cell.x * cell_size, cell.y * cell_size)
	return pos
	

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
	var explosion = explosionObj.instance()
	explosion.set_pos(pos)
	add_child(explosion)
#	explosion.set_owner(self)