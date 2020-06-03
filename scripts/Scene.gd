extends Node2D


var playerLoad = preload("res://objects/Marstine.tscn")
var players = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var screen_size = OS.get_screen_size()
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)


func add_player(id:String,position:Vector2)->void:
	var obj = get_node("Terrain/Transparent/Objects")
	var player = playerLoad.instance()
	player.dummy=true
	player.set_position(position)
	player.set_name(id)
	players[id]=player
	obj.add_child(player)

func remove_player(id:String)->void:
	if players.has(id):
		clean(players[id])
		players.erase(id)

func change_animation(id:String,anim:String)->void:
	if(players.has(id)):
		players[id].change_animation(anim)

func move_player(id:String,pos:Vector2)->void:
	if players.has(id):
		players[id].set_position(pos)

func get_all_pos()->Array:
	var positions = []
	for player in players.keys():
		positions.append([player,players[player].get_position()])
	return positions

func clean(node:Node):
	for nodes in node.get_children():
		if nodes.get_child_count()>0:
			clean(nodes)
	node.queue_free()
