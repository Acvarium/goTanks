extends Node
var current_scene = null
var level = 0
var go = false
var debug_on = false

var player_level = [0,0]
var player_lifes = [1,0]

var levels_data = [
[18,2,0,0,0],
[14,4,0,0,2],
[13,4,0,0,1],
[2,5,10,0,3],
[8,2,3,0,2],
[9,2,4,0,2 ],
[10,4,6,0,0],
[4,4,7,0,2],
[6,4,72,0,1],
[12,2,4,0,2],
]

func default_values(mode):
	
	player_level = [0,0]
	if mode == 0:
		player_lifes = [1,0]
	else:
		player_lifes = [1,1]
		

func _ready():
	var root = get_tree().get_root()
	current_scene = root.get_child( root.get_child_count() -1 )

func goto_scene(path):
	call_deferred("_deferred_goto_scene",path)

func _deferred_goto_scene(path):
	current_scene.free()
	var s = ResourceLoader.load(path)
	current_scene = s.instance()
	get_tree().get_root().add_child(current_scene)
	get_tree().set_current_scene( current_scene )
