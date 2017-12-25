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
export var life = 1
var dead = false
var engine_sound
export var invincible = false
var level = 0
var max_fire_timeout = 1
var max_step_timeout = 3
var bullet_speed = 350

var speed = 0
var max_speed = 150
var velocity = Vector2()

func _ready():
	randomize()
	if type == 1:
		get_node("engine").get_sample_library().get_sample("engine").set_loop_format(1)
		engine_sound = get_node("engine").play("engine")
	main_node = get_node("/root/main")
	get_node("Sprite").set_frame(type * 2)
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
	if type == 1:
		set_process_input(true)
	else:
		get_node("step").start()
		get_node("fireTimer").start()
	
	
func set_level(l):
	level = l
	if type == 0:
		if level == 0:
			max_speed = 150
		elif level == 1:
			max_speed = 250
		elif level == 2:
			max_speed = 400
			max_fire_timeout = 0.5
			max_step_timeout = 1.5
			bullet_speed = 400
		elif level == 3:
			life = 5
			max_speed = 100
		elif level == 4:
			life = 5
			max_speed = 80
			max_bullets = 2
		get_node("Label").set_text(str(level))
			
	
func _input(event):
	if Input.is_action_pressed("fire"):
		fire()

func set_type(t):
	type = t

func fire():
	if bullets_in_air < max_bullets and loaded:
		bullets_in_air += 1
		get_node("fireAnim").play("fire")
		get_node("fire").play("fire")
		var bullet = bulletObj.instance()
		bullet.set_pos(get_node("Sprite/muzzle").get_global_pos())
		bullet.set_speed(bullet_speed)
		bullet.set_direction(currentDir)
		bullet.set_owner(self)
		main_node.get_node("bullets").add_child(bullet)
		loaded = false
		get_node("cooldown").start()

func hit():
	if invincible:
		get_node("fire").play("hit03")
		return
	life -= 1
	if life <= 0:
		dead = true
		main_node.kill_tank(self)
	else:
		get_node("fire").play("hit03")

func _fixed_process(delta):
	if dead:
		return
	direction = Vector2()
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
		if main_node.is_cell_vacant(self):
			target_pos = main_node.update_tank_pos(self)
			is_moving = true
	elif is_moving:
#------ Play animation
		if type == 1:
			get_node("engine").set_pitch_scale(engine_sound, 1)
			get_node("engine").set_volume_db(engine_sound, 3)
		if !get_node("tracksAnim").is_playing():
			get_node("tracksAnim").play("tracks" + str(type))
			
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
		if type == 1:
			get_node("engine").set_pitch_scale(engine_sound, 0.8)
			get_node("engine").set_volume_db(engine_sound, -5)
			
		
		if get_node("tracksAnim").is_playing():
			get_node("tracksAnim").stop(true)
	if direction != Vector2():
		currentDir = direction
	
func free_bullet():
	bullets_in_air -= 1
	if bullets_in_air < 0:
		bullets_in_air = 0

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
	get_node("step").set_wait_time(randf() * max_step_timeout + 0.2)

func _on_fireTimer_timeout():
	get_node("fireTimer").set_wait_time(randf() * max_fire_timeout +0.1)
	fire()


func _on_killer_timeout():
	queue_free()
