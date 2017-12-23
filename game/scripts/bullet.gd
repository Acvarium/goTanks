extends Area2D
var speed = 300
var main_node
var direction = 0

func _ready():
	main_node = get_node("/root/main")
	set_fixed_process(true)
	

func set_direction(dir):
	direction = dir
	if direction == 0:
		set_rot(0)
	elif direction == 1:
		set_rot(PI * 1.5)
	elif direction == 2:
		set_rot(PI)
	elif direction == 3:
		set_rot(PI * 0.5)
		
func _fixed_process(delta):
	var pos = get_pos()
	var rot = get_rot()
	if direction == 0:
		pos.y -= speed * delta
	elif direction == 1:
		pos.x += speed * delta
	elif direction == 2:
		pos.y += speed * delta
	elif direction == 3:
		pos.x -= speed * delta
	set_pos(pos)

func _on_Timer_timeout():
	queue_free()
