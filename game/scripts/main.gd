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
var main_bonuses_at = []
var main_bonus_selected = -1
var max_bots_on_screen = 6

# Bonuses:
# 1 life
# 2 level up
# 3 shild
# 4 granate 
# 5 protected

func _ready():
	randomize()
	get_node("timers/spawn_bonus").set_wait_time(randf()*25 + 10)
	get_node("timers/spawn_bonus").start()
	global = get_node("/root/global")
	level = global.level
	for i in range(5):
		for j in range(global.levels_data[level][i]):
			bots.append(i)
	bots = shuffleList(bots)
	print(bots)
	grid = get_node("grids/grid")
	set_level(level)
	for x in range(world_size):
		world.append([])
		for y in range(world_size):
			world[x].append(null)
		
	if global.player_lifes[0] > 0:
		spawn(1)
	if global.player_lifes[1] > 0:
		spawn(2)
	else:
		$player2_lifes.hide()
	for t in get_node("tanks").get_children():
		update_tank_pos(t)
	get_node("player1_lifes").set_text(str(global.player_lifes[0]))
	get_node("player2_lifes").set_text(str(global.player_lifes[1]))
	if bots.size() > 5:
		main_bonuses_at.append(randi() % (bots.size() - 2) + 1)
		main_bonuses_at.append(randi() % (bots.size() - 2) + 1)
		while(main_bonuses_at[1] == main_bonuses_at[0]):
			main_bonuses_at[1]  = randi() % (bots.size() - 2) + 1
		print(main_bonuses_at[0],' ', main_bonuses_at[1])
	else:
		main_bonuses_at.append(-1)
		main_bonuses_at.append(-1)
		
	$sounds/start.play()
		
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
	elif player == 2:
		global.player_lifes[1] = l
		get_node("player2_lifes").set_text(str(global.player_lifes[1]))
		
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
	var tank_type = tank.type
	if tank.type > 0:
		global.player_lifes[tank.type - 1] -= 1
		global.player_level[tank.type - 1] = 0
		if global.player_lifes[tank_type - 1] <= 0:
			global.player_lifes[tank_type - 1] = 0
		
		if global.player_lifes[0] <= 0 and  global.player_lifes[1] <= 0:
			global.player_lifes[0] = 0
			global.go = true
			$timers/end.start()				#Додати звук поразки
			$UI/end_anim.play("game_over")
			$sounds/failure.play()
	
		$player1_lifes.set_text(str(global.player_lifes[0]))
		$player2_lifes.set_text(str(global.player_lifes[1]))
	elif tank.type == 0:
		killed += 1
			
		if killed >= bots.size():
			global.go = false
#----------------------------------------------
#Додати звук перемоги
			$UI/game_over.text = "  VICTORY"
			$sounds/victory.play()
			$UI/end_anim.play("game_over")
			$timers/end.wait_time = 5
			$timers/end.start()
			
			

		elif killed >= main_bonuses_at[0]  and main_bonuses_at[0] != -1:
			main_bonuses_at[0] = -1
			$timers/main_bonus.wait_time = randf() * 5
			main_bonus_selected = 0
			$timers/main_bonus.start()
		elif killed >= main_bonuses_at[1] and main_bonuses_at[1] != -1:
			main_bonuses_at[1] = -1
			$timers/main_bonus.wait_time = randf() * 5
			main_bonus_selected = 1
			$timers/main_bonus.start()
				
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
	
	if tank_type > 0 and !global.go:
		spawn(tank_type)
		
func spawn(t):
	if t > 0 and global.player_lifes[t - 1] <= 0:
		return
		
	var spawn_pos = Vector2()
	var level = 0
	if t == 1:
		spawn_pos = $spawn_points/point00.position
	elif t == 2:
		spawn_pos = $spawn_points/point01.position
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
	tank.position = spawn_pos
	tank.set_type(t)
	tank.set_name("tank")
	if t > 0:
		tank.set_level(global.player_level[t - 1])
		tank.shild(2)
	else:
		tank.set_level(level)
		
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
			if tile_name[0] == 'h':
				var new_tile_id = grid.tile_set.find_tile_by_name('j' + tile_name[1] + tile_name[2])
				grid.set_cell(cells_pos[i].x,cells_pos[i].y, new_tile_id)
			elif tile_name[0] == 'j':
				var new_tile_id = grid.tile_set.find_tile_by_name('k' + tile_name[1] + tile_name[2])
				grid.set_cell(cells_pos[i].x,cells_pos[i].y, new_tile_id)
			
	if !not_water or !is_grid:
		add_explosion(pos, 0)
	return(!not_water)

func _on_spawn_timer_timeout():
	spawn(0)

func add_explosion(pos, type):
	if type == 0:
		$sounds/hit.play()
#	elif 
	var explosion = explosionObj.instance()
	explosion.position = pos
	explosion.set_explosion(type)
	if type == 2:
		$floor.add_child(explosion)
	else:
		$bullets.add_child(explosion)

func _on_bird_area_enter( area ):
	if area.get_parent().get_name() == "bullets":
		global.go = true
		var bird_pos = $bird.position
		$bird.queue_free()
		add_explosion($bird.position, 1)
		add_explosion($bird.position, 2)
		
		$timers/end.start()
		$UI/end_anim.play("game_over")
		$sounds/failure.play()
#		game_over()

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

func spawn_bonus(type):
	print(type)
	var bonus = bonusObj.instance()
	bonus.position = Vector2(randf() * 864 + 36, randf() * 864 + 36)
	bonus.set_type(type)
	bonus.set_time(randf()*10 + 5)
	$spawn_points.add_child(bonus)
	$sounds/bonus2.play()

func _on_spawn_bonus_timeout():
	spawn_bonus(randi()%5)
	$timers/spawn_bonus.set_wait_time(randf() * 50 + 15)

func _on_end_timeout():
#end of level by fail or vine
	if global.go:
		get_node("/root/global").goto_scene("res://scenes/menu.tscn")
	else:
		get_node("/root/global").goto_scene("res://scenes/score.tscn")

func _on_main_bonus_timeout():
	if main_bonus_selected != -1:
		spawn_bonus(main_bonus_selected)
		main_bonus_selected = -1
