extends Node2D


func _ready():

	pass

func bullet_hit(pos):
	get_node("hit_sound").play("hit")