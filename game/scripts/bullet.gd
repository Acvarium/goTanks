extends Area2D
var speed = 350  
var main_node
var direction = Vector2(0,-1)
var owner_type = 0
var owner
var owner_name
var is_grid = false  #If bullet was hit the grid block

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
	owner = weakref(own)
	owner_type = owner.get_ref().type
	owner_name = owner.get_ref().get_name()
	
func _physics_process(delta):
	position += speed * direction * delta

func _on_Timer_timeout():
	free_bullet()

func _on_bullet_body_entered( body ):
#Do not count owner of a bullet
	if body == owner.get_ref():
		return
	if body.get_parent() == main_node.get_node("grids"):
		is_grid = true
	else:
		is_grid = false
#
#If owner is a BOT
	if owner_type == 0:
		if body.get_parent() == main_node.get_node("tanks"):
			return
		elif body.get_parent() == main_node.get_node("players"):
			body.hit()
		free_bullet()
		
#If owner is player
	elif owner_type > 0:
		if body.get_parent() == main_node.get_node("tanks"):
			body.hit()
			free_bullet()
		else:
			free_bullet()
	else:
		free_bullet()

func free_bullet():
	if main_node.bullet_hit(position, direction, is_grid) or !is_grid:
		if owner.get_ref():
			owner.get_ref().free_bullet()
		queue_free()

func _on_bullet_area_enter( area ):
	is_grid = false
	free_bullet()


