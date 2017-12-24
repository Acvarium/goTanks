extends Node2D


func _ready():
	get_node("exp/exp").play("exp")
	get_node("Timer").start()

func _on_Timer_timeout():
	queue_free()
	