extends Node2D
var global

func _ready():
	global = get_node("/root/global")

func _on_single_player_pressed():
	global.level = 1
	global.tanks = 2
	get_node("/root/global").goto_scene("res://scenes/main.tscn")
