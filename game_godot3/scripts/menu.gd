extends Node2D
var global

func _ready():
	global = get_node("/root/global")

func _on_single_player_pressed():
	global.level = 0
	global.goto_scene("res://scenes/main.tscn")

func _on_single_player1_pressed():
	global.level = 0
	global.goto_scene("res://scenes/main.tscn")

func _on_single_player2_pressed():
	global.level = 1
	global.goto_scene("res://scenes/main.tscn")


func _on_single_player3_pressed():
	global.level = 2
	global.goto_scene("res://scenes/main.tscn")


func _on_single_player4_pressed():
	global.level = 3
	global.goto_scene("res://scenes/main.tscn")


func _on_single_player5_pressed():
	global.level = 4
	global.goto_scene("res://scenes/main.tscn")


func _on_single_player6_pressed():
	global.level = 5
	global.goto_scene("res://scenes/main.tscn")