extends Node2D
var e_set = 0

func set_explosion(e):
	e_set = e

func _ready():
	if e_set == 0:
		get_node("exp/exp").play("exp")
	elif e_set == 1:
		get_node("exp/exp").play("exp2")
	elif e_set == 2:
		get_node("exp/exp").play("dirt")
		get_node("Timer").set_wait_time(2)
		
	get_node("Timer").start()

func _on_Timer_timeout():
	queue_free()
	