extends Node2D
var global

func _ready():

	global = get_node("/root/global")
	if global.go:
		get_node("message").set_text("GAME OVER")
		global.go = false
		global.level = 0
	else:
		global.level += 1
		global.level %= global.levels_data.size()
		get_node("message").set_text("NEXT LEVEL " + str(global.level))
		
	get_node("load_level").start()

func _on_load_level_timeout():
	get_node("/root/global").goto_scene("res://scenes/main.tscn")

