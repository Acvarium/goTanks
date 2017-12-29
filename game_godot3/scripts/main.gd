extends Node2D
var grid
var cell_size = 36
var explosionObj = load("res://objects/explosion.tscn")
var tankObj = load("res://objects/tank.tscn")
var bonusObj = load("res://objects/bonus.tscn")
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
	get_node("timers/spawn_bonus").set_wait_time(randf()*25 + 10)
	get_node("timers/spawn_bonus").start()
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
	set_level(level)
	for x in range(world_size):
		world.append([])
		for y in range(world_size):
			world[x].append(null)
		
	for t in get_node("tanks").get_children():
		update_tank_pos(t)
	get_node("player1_lifes").set_text(str(global.player_lifes[0]))

func _input(event):
	if Input.is_action_pressed("menu"):
		global.goto_scene("res://scenes/menu.tscn")


func shuffleList(list):
    var shuffledList = [] 
    var indexList = range(list.size())
    for i in range(list.size()):
        var x = randi()%indexList.size()
        shuffledList.append(list[indexList[x]])
        indexList.remove(x)
    return shuffledList


#????????????????????????????
func set_level(l):
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
	
func set_player_lifes(l, player):
	if player == 1:
		global.player_lifes[0] = l
		get_node("player1_lifes").set_text(str(global.player_lifes[0]))
		

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

func grenade():
	for t in get_node("tanks").get_children():
		if t.type == 0:
			kill_tank(t)

func kill_tank(tank):
	var is_player1 = false
	if tank.type == 1:
		is_player1 = true
		global.player_lifes[tank.type - 1] -= 1
		global.player_level[tank.type - 1] = 0
		if global.player_lifes[0] <= 0:
			game_over()
	
		get_node("player1_lifes").set_text(str(global.player_lifes[tank.type - 1]))
	elif tank.type == 0:
		killed += 1
		if killed >= bots.size():
			global.go = false
			global.goto_scene("res://scenes/score.tscn")

				
	remove_tank(tank)
	$sounds/explosion.play()
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
		spawn_pos = $spawn_points/point00.position
	elif t == 0:
		var tanks_on_screen = $tanks.get_child_count()
		var spawn_point = randi()%3 + 2
		if !is_spawn_point_vacant(spawn_point) or tanks_on_screen >= max_bots_on_screen or bots_count >= bots.size():
			$timers/spawn_timer.set_wait_time(randf() * 3)
			$timers/spawn_timer.start()
			return
		$timers/spawn_timer.start()
		spawn_pos = get_node("spawn_points/point" + "%02d" % spawn_point).position
		level = bots[bots_count]
		bots_count += 1

	var tank = tankObj.instance()
	tank.set_level(level)
	tank.position = spawn_pos
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

	return target_pos


func world_to_map(pos):
	pos = pos + Vector2(cell_size/4, cell_size/4)
	var cell = Vector2(int(pos.x / cell_size), int(pos.y / cell_size))
	return cell
	
func map_to_world(cell):
	var pos = Vector2(cell.x * cell_size, cell.y * cell_size)
	return pos
	
func bullet_hit(pos, direction, owner, is_grid):
	var not_water = true
	var shift = Vector2(0.5,0)
#	var tail_set = grid.tile_set
	if !abs(direction.y):
		shift = Vector2(0,0.5)
	var cells_pos = [grid.world_to_map(pos + 9 * (direction + shift)), grid.world_to_map(pos + 9 * (direction - shift))]
#	gri
	for i in range(2):
		var tile_name = grid.tile_set.tile_get_name(grid.get_cell(cells_pos[i][0],cells_pos[i][1])) 
		
		if tile_name:
			if tile_name[0] != 'w':
				not_water = false
			print(tile_name + ' ' +  str(grid.tile_set.find_tile_by_name(tile_name)))
			if tile_name[0] == 'h':
				var new_tile_id = grid.tile_set.find_tile_by_name('j' + tile_name[1] + tile_name[2])
				grid.set_cell(cells_pos[i].x,cells_pos[i].y, new_tile_id)
			elif tile_name[0] == 'j':
				var new_tile_id = grid.tile_set.find_tile_by_name('k' + tile_name[1] + tile_name[2])
				grid.set_cell(cells_pos[i].x,cells_pos[i].y, new_tile_id)
			
	if !not_water or !is_grid:
		$sounds/hit.play()
		var explosion = explosionObj.instance()
		explosion.position = pos
		$bullets.add_child(explosion)
	return(!not_water)

func _on_spawn_timer_timeout():
	spawn(0)


func game_over():
	global.go = true
	get_node("/root/global").goto_scene("res://scenes/score.tscn")
		

func _on_bird_area_enter( area ):
	if area.get_parent().get_name() == "bullets":
		game_over()
	

func protect():
	grid.set_cell(11,23,2)
	grid.set_cell(12,23,2)
	grid.set_cell(13,23,2)
	grid.set_cell(14,23,2)
	grid.set_cell(11,24,2)
	grid.set_cell(11,25,2)
	grid.set_cell(14,24,2)
	grid.set_cell(14,25,2)
	get_node("timers/protected").start()
	
func _on_protected_timeout():
	grid.set_cell(11,23,grid.tile_set.find_tile_by_name('h00'))
	grid.set_cell(12,23,grid.tile_set.find_tile_by_name('h01'))
	grid.set_cell(13,23,grid.tile_set.find_tile_by_name('h01'))
	grid.set_cell(14,23,grid.tile_set.find_tile_by_name('h02'))
	grid.set_cell(11,24,grid.tile_set.find_tile_by_name('h03'))
	grid.set_cell(11,25,grid.tile_set.find_tile_by_name('h03'))
	grid.set_cell(14,24,grid.tile_set.find_tile_by_name('h05'))
	grid.set_cell(14,25,grid.tile_set.find_tile_by_name('h05'))

func play_sound(sound):
	if sound == 'up':
		$sounds/bonus.play()


func _on_spawn_bonus_timeout():
	var bonus = bonusObj.instance()
	bonus.position = Vector2(randf() * 864 + 36, randf() * 864 + 36)
	bonus.set_type(randi()%5)
	bonus.set_time(randf()*10 + 5)
	get_node("spawn_points").add_child(bonus)
	get_node("timers/spawn_bonus").set_wait_time(randf()*25 + 10)
	$sounds/bonus2.play()
#	get_node("sounds/effect").play("up02")
	
