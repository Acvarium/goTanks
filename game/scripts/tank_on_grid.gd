extends KinematicBody2D

export var type = 0
export var lavel = 0
var direction = Vector2()
var currentDir = Vector2(0,-1)
var grid 
var is_moving = false
var target_pos = Vector2()
var target_direction = Vector2()
var bulletObj = load("res://objects/bullet.tscn")
var main_node
var bullets_in_air = 0
var max_bullets = 1
enum ENTITY_TYPES {UP, DOWN, LEFT, RIGHT}
var loaded = true
var randDir = -1

var speed = 0
var max_speed = 150
var velocity = Vector2()

func _ready():
	randomize()
	main_node = get_node("/root/main")
	get_node("rays/rayUp").add_exception(self)
	get_node("rays/rayDown").add_exception(self)
	get_node("rays/rayLeft").add_exception(self)
	get_node("rays/rayRight").add_exception(self)
	get_node("rays/rayUp1").add_exception(self)
	get_node("rays/rayDown1").add_exception(self)
	get_node("rays/rayLeft1").add_exception(self)
	get_node("rays/rayRight1").add_exception(self)
	grid = get_parent()
	set_fixed_process(true)
#	set_process_input(true)
	if type == 1:
		set_process_input(true)
	else:
		get_node("step").start()
		get_node("fireTimer").start()
	
func _input(event):
	if Input.is_action_pressed("fire"):
		fire()

func fire():
	if bullets_in_air < max_bullets and loaded:
		bullets_in_air += 1
		get_node("fireAnim").play("fire")
		get_node("fire").play("fire")
		var bullet = bulletObj.instance()
		bullet.set_pos(get_node("Sprite/muzzle").get_global_pos())
		bullet.set_direction(currentDir)
		bullet.set_owner(self)
		main_node.get_node("bullets").add_child(bullet)
		loaded = false
		get_node("cooldown").start()

func _fixed_process(delta):
	direction = Vector2()
#	if isinco
	if Input.is_action_pressed("ui_up") and type == 1 or randDir == 0 and type == 0:
		currentDir = Vector2(0,-1)
		if !obstacle(UP):
			direction.y = -1
		if !is_moving:
			get_node("Sprite").set_rot(0)
	elif Input.is_action_pressed("ui_down") and type == 1 or randDir == 1 and type == 0:
		currentDir = Vector2(0,1)
		if !obstacle(DOWN):
			direction.y = 1
		if !is_moving:
			get_node("Sprite").set_rot(PI)
	elif Input.is_action_pressed("ui_left") and type == 1 or randDir == 2 and type == 0:
		currentDir = Vector2(-1,0)
		if !obstacle(LEFT):
			direction.x = -1
		if !is_moving:
			get_node("Sprite").set_rot(PI/2)
	elif Input.is_action_pressed("ui_right") and type == 1 or randDir == 3 and type == 0:
		currentDir = Vector2(1,0)
		if !obstacle(RIGHT):
			direction.x = 1
		if !is_moving:
			get_node("Sprite").set_rot(PI*1.5)
	if not is_moving and direction != Vector2():
		target_direction = direction
#		if grid.is_cell_vacant(get_pos(),target_direction):
		target_pos = update_pos()
		is_moving = true
	elif is_moving:
#------ Play animation
		if !get_node("tracksAnim").is_playing():
			get_node("tracksAnim").play("tracks")
			
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
	else:
#------ Stop animation
		if get_node("tracksAnim").is_playing():
			get_node("tracksAnim").stop(true)
	if direction != Vector2():
		currentDir = direction
			
func free_bullet():
	bullets_in_air -= 1
	if bullets_in_air < 0:
		bullets_in_air = 0

func update_pos():
	var grid_pos = main_node.world_to_map(get_pos())
	var new_grid_pos = grid_pos + direction
	var target_pos = main_node.map_to_world(new_grid_pos)
	return target_pos

func obstacle(dir):
	if dir == UP:
		return get_node("rays/rayUp").is_colliding() or get_node("rays/rayUp1").is_colliding()
	elif dir == DOWN:
		return get_node("rays/rayDown").is_colliding() or get_node("rays/rayDown1").is_colliding()
	elif dir == LEFT:
		return get_node("rays/rayLeft").is_colliding() or get_node("rays/rayLeft1").is_colliding()
	elif dir == RIGHT:
		return get_node("rays/rayRight").is_colliding() or get_node("rays/rayRight1").is_colliding()


func _on_cooldown_timeout():
	loaded = true
	
func _on_step_timeout():
	randDir = randi()%5
	get_node("step").set_wait_time(randf()*3+0.2)

func _on_fireTimer_timeout():
	get_node("fireTimer").set_wait_time(randf()+0.1)
	fire()
