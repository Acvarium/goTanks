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
var bots = []
var bots_count = 0
var killed = 0

var max_bots_on_screen = 6

func _ready():
	global = get_node("/root/global")
	level = global.level
	for i in range(5):
		for j in range(global.levels_data[level][i]):
			bots.append(i)
	bots = shuffleList(bots)
	var ta = ""
	for b in bots:
		ta += str(b) + "\n"
	grid = get_node("grids/grid")
	change_level(level)
	for x in range(world_size):
		world.append([])
		for y in range(world_size):
			world[x].append(null)
		
	for t in get_node("tanks").get_children():
		update_tank_pos(t)

func shuffleList(list):
    var shuffledList = [] 
    var indexList = range(list.size())
    for i in range(list.size()):
        var x = randi()%indexList.size()
        shuffledList.append(list[indexList[x]])
        indexList.remove(x)
    return shuffledList

func change_level(l):
	level = l
	if $grids.has_node("grid"):
		$grids/grid.queue_free()
		var name = "level" + "%02d" % level + ".tscn"
		
		mapObj = load("res://levels/" + name)
		var map = mapObj.instance()
		map.set_name("grid")
		$grids.add_child(map)
		grid = map

func is_spawn_point_vacant(point):
	var point_name = "spawn_points/point" + "%02d" % point 
	
	var grid_pos = world_to_map(get_node(point_name).position)
	for x in range(2):
		for y in range(2):
			var cell = world[grid_pos.x + x - 1][grid_pos.y + y - 1]
			if cell != null:
				return false
	return true
	

func is_cell_vacant(tank):
	var direction = tank.direction
	var grid_pos = world_to_map(tank.position) + direction
	for x in range(2):
		for y in range(2):
			if (grid_pos.x + x - 1) < 0 or (grid_pos.x + x - 1) >= world.size():
				return false
			if (grid_pos.y + y - 1) < 0 or (grid_pos.y + y - 1) >= world[0].size():
				return false
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
		if global.player1_lifes <= 0:
			game_over()
	
	elif tank.type == 0:
		killed += 1
		if killed >= bots.size():
			global.go = false
			global.goto_scene("res://scenes/score.tscn")

				
	remove_tank(tank)
#	get_node("hit_sound").play("explosion02")
	var explosion = explosionObj.instance()
	explosion.position = tank.position
	explosion.set_explosion(1)
	$bullets.add_child(explosion)

	
	var dirt = explosionObj.instance()
	dirt.position = tank.position
	dirt.set_explosion(2)
	$floor.add_child(dirt)
	tank.queue_free()
	if is_player1:
		spawn(1)
		
func spawn(t):
	var spawn_pos = Vector2()
	var type = t
	var level = 0
	if t == 1:
		spawn_pos = $spawn_points/point00.get_pos()
	elif t == 0:
		var tanks_on_screen = $tanks.get_child_count()
		var spawn_point = randi()%3 + 2
		if !is_spawn_point_vacant(spawn_point) or tanks_on_screen >= max_bots_on_screen or bots_count >= bots.size():
			$spawn_timer.set_wait_time(randf() * 3)
			$spawn_timer.start()
			return
		$spawn_timer.start()
		spawn_pos = get_node("spawn_points/point" + "%02d" % spawn_point).position
		level = bots[bots_count]
		bots_count += 1

	var tank = tankObj.instance()
	tank.set_level(level)
	tank.set_pos(spawn_pos)
	tank.set_type(type)
	tank.set_name("tank")
	
	$tanks.add_child(tank)
	update_tank_pos(tank)


func remove_tank(tank):
	var grid_pos = world_to_map(tank.position)
	for x in range(world_size):
		for y in range(world_size):
			if world[x][y] == tank:
				world[x][y] = null

func update_tank_pos(tank):
	remove_tank(tank)
	var grid_pos = world_to_map(tank.position)
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
#	get_node("hit_sound").play("hit")
	var explosion = explosionObj.instance()
	explosion.position = pos
	$bullets.add_child(explosion)

func _on_spawn_timer_timeout():
	spawn(0)


func game_over():
	global.go = true
	get_node("/root/global").goto_scene("res://scenes/score.tscn")
		

func _on_bird_area_enter( area ):
	if area.get_parent().get_name() == "bullets":
		game_over()
	