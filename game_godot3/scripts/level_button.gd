extends Node2D
export var level = 0
var main_node

func _ready():
	main_node = get_node("/root/main")
	$Button.text = str(level)
	
func set_level(l):
	level = l
	$Button.text = str(level)
	
func _on_Button_pressed():
	global.level = level
	global.goto_scene("res://scenes/main.tscn")


func _on_Button_mouse_entered():
	main_node.mouse_over(level)


func _on_Button_mouse_exited():
	main_node.mouse_exited()
