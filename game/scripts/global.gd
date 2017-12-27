extends Node
var current_scene = null
var level = 0
var go = false

var player_level = [0,0]
var player_lifes = [2,0]

var levels_data = [
[18,0,2,0,0],
[11,0,4,0,2],
[10,0,4,0,2]
]

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