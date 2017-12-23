extends Area2D
var speed = 300
var main_node
var direction = Vector2(0,-1)
var ownerType = 0
var owner

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
	if owner.get_name() == 'tank':
		ownerType = 1
	
func _fixed_process(delta):
	var pos = get_pos()
	var rot = get_rot()
	pos += speed * direction * delta
	set_pos(pos)

func _on_Timer_timeout():
	free_bullet()

func _on_bullet_body_enter( body ):
	if ownerType == 1:
		if body.get_name() != 'tank':
			free_bullet()
	else:
			free_bullet()

func free_bullet():
	if owner:
		owner.free_bullet()
	main_node.bullet_hit(get_pos())
	queue_free()
