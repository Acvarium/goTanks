extends KinematicBody2D

export var type = 0 
export var lavel = 0
var direction = Vector2()
var currentDir = Vector2(0,-1)
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
export var invincible = false
var level = 0
var max_fire_timeout = 1
var max_step_timeout = 3
var bullet_speed = 350

var speed = 0
var max_speed = 150
var velocity = Vector2()

#Player Levels Data
# 0 max_speed
# 1 bullet_speed
# 2 max_bullets

const PLD = [
[150, 350, 1],
[150, 350, 2],
[150, 420, 2],
[180, 430, 2]
]

#Bot Levels Data
# 0 max_speed
# 1 bullet_speed
# 2 max_bullets
# 3 max_step_timeout
# 4 max_fire_timeout
# 5 life
const BLD = [
[150, 350, 1, 3, 1, 1],
[250, 350, 1, 1.5, 1, 1],
[400, 410, 1, 1.5, 0.5, 1],
[100, 350, 1, 3, 1, 4],
[80, 350, 2, 3, 1, 5],
]

func _ready():
	randomize()
#	if type == 1:
#		get_node("engine").get_sample_library().get_sample("engine").set_loop_format(1)
#		engine_sound = get_node("engine").play("engine")
#		set_level(global.player_level[type - 1])
	main_node = get_node("/root/main")
	$Sprite.set_frame(type * 2)
	$rays/rayUp.add_exception(self)
	$rays/rayDown.add_exception(self)
	$rays/rayLeft.add_exception(self)
	$rays/rayRight.add_exception(self)
	$rays/rayUp1.add_exception(self)
	$rays/rayDown1.add_exception(self)
	$rays/rayLeft1.add_exception(self)
	$rays/rayRight1.add_exception(self)
	if type == 1:
		$sounds/engine.play()
		pass
	elif type == 0:
		$sounds/fire.volume_db = -40
		$timers/step.start()
		$timers/fireTimer.start()
	
	
func set_level(l):
	level = l
	if type == 0:
		max_speed = BLD[level][0]
		bullet_speed = BLD[level][1]
		max_bullets = BLD[level][2]
		max_step_timeout = BLD[level][3]
		max_fire_timeout = BLD[level][4]
		life = BLD[level][5]
	else:
#Set Level for player
		if level > PLD.size() - 1:
			level = PLD.size() - 1
		global.player_level[type - 1] = level
		max_speed = PLD[level][0]
		bullet_speed = PLD[level][1]
		max_bullets = PLD[level][2]
	get_node("Label").set_text(str(level))
	
	
func _input(event):
	if Input.is_action_pressed("fire"):
		fire()

func set_type(t):
	type = t

func fire():
	if bullets_in_air < max_bullets and loaded:
		bullets_in_air += 1
#		$fireAnim.play("fire")
		$sounds/fire.play()
		
		var bullet = bulletObj.instance()
		bullet.position = get_node("Sprite/muzzle").global_position
		bullet.set_speed(bullet_speed)
		bullet.set_direction(currentDir)
		bullet.set_owner(self)
		main_node.get_node("bullets").add_child(bullet)
		loaded = false
		$timers/cooldown.start()

func hit():
	if invincible:
		$sounds/hit2.play()
		
		return
	life -= 1
	if life <= 0:
		dead = true
		main_node.kill_tank(self)
	else:
		pass
		$sounds/hit2.play()

func _physics_process(delta):
	if dead:
		return
	direction = Vector2()
	if Input.is_action_pressed("ui_up") and type == 1 or randDir == 0 and type == 0:
		if !obstacle(UP):
			direction.y = -1
		if !is_moving:
			currentDir = Vector2(0,-1)
			$Sprite.rotation = 0
	elif Input.is_action_pressed("ui_down") and type == 1 or randDir == 1 and type == 0:
		if !obstacle(DOWN):
			direction.y = 1
		if !is_moving:
			currentDir = Vector2(0,1)
			$Sprite.rotation = PI
	elif Input.is_action_pressed("ui_left") and type == 1 or randDir == 2 and type == 0:
		if !obstacle(LEFT):
			direction.x = -1
		if !is_moving:
			currentDir = Vector2(-1,0)
			$Sprite.rotation = PI*1.5
	elif Input.is_action_pressed("ui_right") and type == 1 or randDir == 3 and type == 0:
		if !obstacle(RIGHT):
			direction.x = 1
		if !is_moving:
			currentDir = Vector2(1,0)
			$Sprite.rotation = PI/2 
			
	
	if not is_moving and direction != Vector2():
		target_direction = direction
		if main_node.is_cell_vacant(self):
			target_pos = main_node.update_tank_pos(self)
			is_moving = true
	elif is_moving:
#------ Play animation
		if type == 1:
			pass
			$sounds/engine.stop()
			if !$sounds/engine2.playing:
				$sounds/engine2.play()
		if !$tracksAnim.is_playing():
			$tracksAnim.play("tracks" + str(type))
			
		speed = max_speed
		velocity = speed * target_direction * delta
		var distance_to_target = Vector2(abs(target_pos.x - position.x), abs(target_pos.y - position.y))
		if abs(velocity.x) > distance_to_target.x:
			velocity.x = distance_to_target.x * target_direction.x
			is_moving = false
			
		if abs(velocity.y) > distance_to_target.y:
			velocity.y = distance_to_target.y * target_direction.y
			is_moving = false
		move_and_collide(velocity)
	else:
#------ Stop animation
		if type == 1:
			pass
			if !$sounds/engine.playing:
				$sounds/engine.play()
			$sounds/engine2.stop()
			
		if $tracksAnim.is_playing():
			$tracksAnim.stop(true)

func free_bullet():
	bullets_in_air -= 1
	if bullets_in_air < 0:
		bullets_in_air = 0

func obstacle(dir):
	if dir == UP:
		return $rays/rayUp.is_colliding() or $rays/rayUp1.is_colliding()
	elif dir == DOWN:
		return $rays/rayDown.is_colliding() or $rays/rayDown1.is_colliding()
	elif dir == LEFT:
		return $rays/rayLeft.is_colliding() or $rays/rayLeft1.is_colliding()
	elif dir == RIGHT:
		return $rays/rayRight.is_colliding() or $rays/rayRight1.is_colliding()

func shild():
	get_node("shild").show()
	get_node("timers/shild").start()
	invincible = true

func _on_cooldown_timeout():
	loaded = true

func _on_step_timeout():
	randDir = randi()%5
	$timers/step.set_wait_time(randf() * max_step_timeout + 0.2)

func _on_fireTimer_timeout():
	$timers/fireTimer.set_wait_time(randf() * max_fire_timeout +0.1)
	fire()


func _on_killer_timeout():
	queue_free()

func _on_shild_timeout():
	invincible = false
	get_node("shild").hide()

func _on_fire_finished():
	$sounds/fire.stop()
