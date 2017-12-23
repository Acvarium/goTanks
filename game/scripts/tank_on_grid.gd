extends KinematicBody2D

var direction = Vector2()
var grid 
var is_moving = false
var target_pos = Vector2()
var target_direction = Vector2()

var speed = 0
var max_speed = 150
var velocity = Vector2()

func _ready():
	get_node("rays/rayUp").add_exception(self)
	get_node("rays/rayDown").add_exception(self)
	get_node("rays/rayLeft").add_exception(self)
	get_node("rays/rayRight").add_exception(self)
	grid = get_parent()
	set_fixed_process(true)
	

func _fixed_process(delta):
	direction = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		if !get_node("rays/rayUp").is_colliding():
			direction.y = -1
		if !is_moving:
			get_node("Sprite").set_rot(0)
	elif Input.is_action_pressed("ui_down"):
		if !get_node("rays/rayDown").is_colliding():
			direction.y = 1
		if !is_moving:
			get_node("Sprite").set_rot(PI)
	elif Input.is_action_pressed("ui_left"):
		if !get_node("rays/rayLeft").is_colliding():
			direction.x = -1
		if !is_moving:
			get_node("Sprite").set_rot(PI/2)
	elif Input.is_action_pressed("ui_right"):
		if !get_node("rays/rayRight").is_colliding():
			direction.x = 1
		if !is_moving:
			get_node("Sprite").set_rot(PI*1.5)

	if not is_moving and direction != Vector2():
		target_direction = direction
#		if grid.is_cell_vacant(get_pos(),target_direction):
		target_pos = update_pos()
		is_moving = true
	elif is_moving:
		speed = max_speed
		velocity = speed * target_direction * delta
		var pos = get_pos()
		var distance_to_target = Vector2(abs(target_pos.x - pos.x), abs(target_pos.y - pos.y))
		if abs(velocity.x) > distance_to_target.x:
			velocity.x = distance_to_target.x * target_direction.x
			is_moving = false
			
		if abs(velocity.y) > distance_to_target.y:
			velocity.y = distance_to_target.y * target_direction.y
			is_moving = false
			
		move(velocity)

func update_pos():
	var grid_pos = grid.world_to_map(get_pos())
	var new_grid_pos = grid_pos + direction
	var target_pos = grid.map_to_world(new_grid_pos)
	return target_pos
