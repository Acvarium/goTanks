extends Node2D
var global
var buttonObj = load("res://objects/level_button.tscn") 

func _ready():
	global = get_node("/root/global")
	for i in range(global.levels_data.size()):
		print(i)
		var button = buttonObj.instance()
		button.position = $pos.position
		button.position.y += i * 36
		button.set_level(i)
		$buttons.add_child(button)
	
func _on_single_player_pressed():
	global.level = 0
	print('aaaaaaaaaaaaaaaaaaa')
	global.goto_scene("res://scenes/main.tscn")
