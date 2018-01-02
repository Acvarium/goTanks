extends Node2D
var global
var buttonObj = load("res://objects/level_button.tscn") 


func _ready():
	global = get_node("/root/global")
	for i in range(global.levels_data.size()):
		var button = buttonObj.instance()
		button.position = $pos.position
		button.position.y += i * 36
		button.set_level(i)
		$sButtons.add_child(button)
	
func _on_single_player_pressed():
	global.level = 0
	global.player_lifes = [1,0]
	global.goto_scene("res://scenes/main.tscn")


func mouse_over(level):
	var directory = Directory.new();
	var file_name ="res://textures/prev/l" + "%02d" % level + ".png"
	if directory.file_exists(file_name):
		var texture = load(file_name) 
		$preview.texture = texture
		$anim.stop(true)
		$preview.modulate = Color(1,1,1,1)
		
	
func mouse_exited():
	$anim.play("f")

func _on_single_player_mouse_entered():
	mouse_over(0)


func _on_single_player_mouse_exited():
	mouse_exited()


func _on_double_player_pressed():
	global.level = 0
	global.player_lifes = [1,1]
	global.goto_scene("res://scenes/main.tscn")

#OS.shell_open("http://godotengine.org")

func _on_godot_pressed():
	OS.shell_open("http://godotengine.org")

func _on_inkscape_pressed():
	OS.shell_open("https://inkscape.org/")

func _on_link_pressed():
	OS.shell_open("https://github.com/Acvarium/goTanks")

func _on_single_pressed():
	global.level = 0
	global.player_lifes = [1,0]
	global.player_level = [0,0]
	global.goto_scene("res://scenes/main.tscn")

func _on_double_pressed():
	global.level = 0
	global.player_lifes = [1,1]
	global.player_level = [0,0]
	global.goto_scene("res://scenes/main.tscn")

func _on_select_pressed():
	global.goto_scene("res://scenes/levels.tscn")

func _on_back_pressed():
	global.goto_scene("res://scenes/menu.tscn")
