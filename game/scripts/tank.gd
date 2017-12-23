extends KinematicBody2D

var speed = 150
var engine_sound
var bulletObj = load("res://objects/bullet.tscn")
var main_node
var dir = 0
const GS = 36
var on_grid = Vector2(0,0)

func _ready():
	main_node = get_node("/root/main")
	get_node("engine").get_sample_library().get_sample("engine").set_loop_format(1)
	engine_sound = get_node("engine").play("engine")
	set_fixed_process(true)
	set_process_input(true)
	on_grid.x = int(get_pos().x / GS)
	on_grid.y = int(get_pos().y / GS)
	print(on_grid)
	set_pos(Vector2(on_grid.x * GS, on_grid.y * GS))
	
	
func _input(event):
	if Input.is_action_pressed("fire"):
		fire()

func fire():
	get_node("fireAnim").play("fire")
	get_node("fire").play("fire")
	var bullet = bulletObj.instance()
	bullet.set_pos(get_node("muzzle").get_global_pos())
	bullet.set_direction(dir)
	main_node.get_node("bullets").add_child(bullet)

func dir_to_vel():
	var vel = Vector2(0,0)
	if dir == 0:
		vel.y = -speed
	elif dir == 1:
		vel.x = speed
	elif dir == 2:
		vel.y = speed
	elif dir == 3:
		vel.x = -speed
	return vel

func _fixed_process(delta):
	var released = false
	var velocity = Vector2(0,0)
	var INITIAL_ANGLE = get_node("track").PARAM_INITIAL_ANGLE
	if Input.is_action_pressed("ui_up"):
		set_rot(0)
		get_node("track").set_param(INITIAL_ANGLE, 0)
		dir = 0
	elif Input.is_action_pressed("ui_down"):
		set_rot(PI)
		get_node("track").set_param(INITIAL_ANGLE, 0)
		dir = 2
	elif Input.is_action_pressed("ui_left"):
		set_rot(PI*0.5)
		get_node("track").set_param(INITIAL_ANGLE, 90)
		dir = 3
	elif Input.is_action_pressed("ui_right"):
		set_rot(PI*1.5)
		get_node("track").set_param(INITIAL_ANGLE, 90)
		dir = 1
	else:
		released = true
		
	if !released:
		velocity = dir_to_vel()
		if !get_node("tracksAnim").is_playing():
			get_node("tracksAnim").play("tracks")
			get_node("track").set_emitting(true)
			get_node("engine").set_pitch_scale(engine_sound, 1)
	else:
		if get_node("tracksAnim").is_playing():
			get_node("tracksAnim").stop(true)
			get_node("track").set_emitting(false)
			get_node("engine").set_pitch_scale(engine_sound, 0.8)
	
	move(velocity * delta)