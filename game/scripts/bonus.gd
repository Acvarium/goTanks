extends Sprite
export var type = 0
var time = 20
var main_node 
var global 
var value = 1

func set_type(t):
	type = t
	set_frame(type)

func set_time(t):
	time = t
	get_node("Timer").set_wait_time(t)
	
func _ready():
	global = get_node("/root/global")
	main_node = get_node("/root/main")
	get_node("anim").play("blink")
	set_process(true)
	set_frame(type)
	
func _process(delta):
	var time_left = get_node("Timer").get_time_left()
	var speed = ((time - time_left) / time * 2) + 1
	get_node("anim").set_speed_scale(speed)

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_enter( body ):
	if value > 0:
		if body.get_parent() == main_node.get_node("tanks"):
			if body.type > 0:
				main_node.play_sound("up")
				disappear()
				if type == 0:
					main_node.set_player_lifes(global.player_lifes[body.type - 1] + 1, body.type)
				elif type == 1:
					body.set_level(global.player_level[body.type - 1] + 1)
				elif type == 2:
					body.shild(10)
				elif type == 3:
					main_node.grenade()
				elif type == 4:
					main_node.protect()
				elif type == 5:
					main_node.froze()

func disappear():
	value -= 1
	set_process(false)
	get_node("anim").stop(true)
	get_node("Timer").set_wait_time(0.2)
	get_node("Timer").start()
	set_modulate(Color(1,1,0.5,1))

func _on_Area2D_area_enter( area ):
	if area.get_parent() == main_node.get_node("bullets"):
		disappear()
