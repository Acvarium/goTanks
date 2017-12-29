extends Area2D
var speed = 350
var main_node
var direction = Vector2(0,-1)
var owner_type = 0
var owner
var owner_name
var wr
var is_grid = false

func set_speed(s):
	speed = s

func _ready():
	main_node = get_node("/root/main")
	
func set_direction(dir):
	direction = dir
	if direction.y == -1:
		rotation = 0
	elif direction.x == 1:
		rotation = PI * 0.5
	elif direction.y == 1:
		rotation = PI
	elif direction.x == -1:
		rotation = PI * 1.5
		
func set_owner(own):
	owner = own
	owner_type = owner.type
	owner_name = owner.get_name()
	wr = weakref(owner)

	
func _physics_process(delta):
	position += speed * direction * delta


func _on_Timer_timeout():
	free_bullet()


func _on_bullet_body_entered( body ):
#Do not count owner of a bullet
	if body == owner:
		return
	if body.get_parent() == main_node.get_node("grids"):
		is_grid = true
	else:
		is_grid = false
#
#If owner is a BOT
	if owner_type == 0:
		
		if body.get_parent() == main_node.get_node("tanks"):
			if body.type == 0:
				return
			else:
				body.hit()
		free_bullet()
		
#If owner is player
	elif owner_type == 1:
		if body.get_parent() == main_node.get_node("tanks"):
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
	print('hit')
	if main_node.bullet_hit(position, direction, owner, is_grid) or !is_grid:
		if owner:
			if (wr.get_ref()):
				owner.free_bullet()
		queue_free()

func _on_bullet_area_enter( area ):
	is_grid = false
	free_bullet()


