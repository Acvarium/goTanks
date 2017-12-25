extends Area2D
var speed = 300
var main_node
var direction = Vector2(0,-1)
var owner_type = 0
var owner
var owner_name

func _ready():
	main_node = get_node("/root/main")
	set_fixed_process(true)
	
func set_direction(dir):
	direction = dir
	if direction.y == -1:
		set_rot(0)
	elif direction.x == 1:
		set_rot(PI * 1.5)
	elif direction.y == 1:
		set_rot(PI)
	elif direction.x == -1:
		set_rot(PI * 0.5)
		
func set_owner(own):
	owner = own
	owner_type = owner.type
	owner_name = owner.get_name()

	
func _fixed_process(delta):
	var pos = get_pos()
	var rot = get_rot()
	pos += speed * direction * delta
	set_pos(pos)

func _on_Timer_timeout():
	free_bullet()

func _on_bullet_body_enter( body ):
	if body == owner:
		return
	if owner_type == 0:
		if body.get_name()[0] == 't':
			if body.type == 0:
				return
		free_bullet()
	elif owner_type == 1:
		if body.get_name()[0] == 't':
			if body.type == 1:
				return
			elif body.type == 0:
				body.hit()
				free_bullet()
		else:
			free_bullet()
	else:
		free_bullet()

func free_bullet():
	if owner:
		if main_node.has_node("tanks/" + owner_name):
			owner.free_bullet()
	main_node.bullet_hit(get_pos(), direction)
	queue_free()


func _on_bullet_area_enter( area ):
	free_bullet()
