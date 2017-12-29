extends Node2D
export var level = 0

func _ready():
	$Button.text = str(level)

func set_level(l):
	level = l
	$Button.text = str(level)
	
func _on_Button_pressed():
	global.level = level
	global.goto_scene("res://scenes/main.tscn")
