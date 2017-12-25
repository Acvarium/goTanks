extends Node2D
var grid
var cell_size = 36
var explosionObj = load("res://objects/explosion.tscn")
var tankObj = load("res://objects/tank.tscn")
const world_size = 26
var world = []
var level
var mapObj
var global 

func _ready():
	global = get_node("/root/global")
	level = global.level
	get_node("player1_lifes").set_text(str(global.player1_lifes))
	grid = get_node("grid")
	change_level(level)
	for x in range(world_size):
		world.append([])
		for y in range(world_size):
			world[x].append(null)

func change_level(l):
	level = l
	if has_node("grid"):
		get_node("grid").queue_free()
		var name = "level" + "%02d" % level + ".tscn"
		
		mapObj = load("res://levels/" + name)
		var map = mapObj.instance()
		map.set_name("grid")
		add_child(map)
		grid = map

func is_cell_vacant(tank):
	var direction = tank.direction
	var pos = tank.get_pos()
	var grid_pos = world_to_map(pos) + direction
#	if world[grid_pos.x][grid_pos.y] == null:
	for x in range(2):
		for y in range(2):
			var cell = world[grid_pos.x + x - 1][grid_pos.y + y - 1]
			if cell != null:
				if cell != tank:
					return false
	return true

func kill_tank(tank):
	var is_player1 = false
	if tank.type == 1:
		is_player1 = true
		global.player1_lifes -= 1
		get_node("player1_lifes").set_text(str(global.player1_lifes))
	remove_tank(tank)
	get_node("hit_sound").play("explosion02")
	var explosion = explosionObj.instance()
	explosion.set_pos(tank.get_pos())
	explosion.set_explosion(1)
	get_node("bullets").add_child(explosion)
	
	var dirt = explosionObj.instance()
	dirt.set_pos(tank.get_pos())
	dirt.set_explosion(2)
	get_node("floor").add_child(dirt)
	tank.queue_free()
	if is_player1:
		spawn_player(0)
		
func spawn_player(player_num):
	var spawn_pos = Vector2()
	var type = 1
	if player_num == 0:
		spawn_pos = get_node("spawn_points/point01").get_pos()
	var player = tankObj.instance()
	player.set_pos(spawn_pos)
	player.set_type(type)
	player.set_name("tank")
	get_node("tanks").add_child(player)

func remove_tank(tank):
	var grid_pos = world_to_map(tank.get_pos())
	for x in range(world_size):
		for y in range(world_size):
			if world[x][y] == tank:
				world[x][y] = null

func update_tank_pos(tank):
	remove_tank(tank)
	var grid_pos = world_to_map(tank.get_pos())
	var new_grid_pos = grid_pos + tank.direction
	for x in range(2):
		for y in range(2):
			world[new_grid_pos.x + x - 1][new_grid_pos.y + y - 1] = tank
	
	var target_pos = map_to_world(new_grid_pos) 
	var t = ''
	for x in range(world_size):
		for y in range(world_size):
			if world[y][x] != null:
				t += "[" + world[y][x].get_name()[-1] + "]"
			else:
				t += "[  ]"
		t += '\n'
	get_node("Label").set_text(t)
	var ta = ""
	for taa in get_node("tanks").get_children():
		ta += taa.get_name() + "\n"
	get_node("player1_lifes1").set_text(ta)
	return target_pos


func world_to_map(pos):
	pos = pos + Vector2(cell_size/4, cell_size/4)
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
			grid.set_cell(cells_pos[i].x,cells_pos[i].y,1)
		elif cells_id[i] == 1:
			grid.set_cell(cells_pos[i].x,cells_pos[i].y,-1)
#	
	get_node("hit_sound").play("hit")
	var explosion = explosionObj.instance()
	explosion.set_pos(pos)
	get_node("bullets").add_child(explosion)
	

	
	