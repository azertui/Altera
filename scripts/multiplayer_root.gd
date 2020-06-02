extends Node


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"

var gameLoad = preload("res://game.tscn")
var game = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# creates an empty game instance
func load_game()->void:
	game = gameLoad.instance()
	#remove all tiles
	game.get_node("Terrain").clear()
	game.get_node("Terrain/Transparent").clear()
	game.get_node("Terrain/Transparent/Objects").clear()
	#remove bridges area2d
	for child in game.get_node("Bridges").get_children():
		clean(child)

func connect_to(ip:String)->void:
	var succeeded = false
	if succeeded:
		remove_menu()
		load_game()
		set_game(null,null,null,null,null)
	else:
		get_node("multiplayer").connection_fail()

func get_mapInfo()->Array:
	var TerrainTiles = []
	var ObjectTiles = []
	var TransparentTiles = []
	var bridges = []
	var terrain = game.get_node("Terrain")
	var transparent = game.get_node("Terrain/Transparent")
	var object = game.get_node("Terrain/Transparent/Objects")
	for tile in terrain.get_used_cells():
		TerrainTiles.append([tile.x,tile.y,terrain.get_cell(tile.x,tile.y)])
	for tile in transparent.get_used_cells():
		TransparentTiles.append([tile.x,tile.y,transparent.get_cell(tile.x,tile.y)])
	for tile in object.get_used_cells():
		ObjectTiles.append([tile.x,tile.y,object.get_cell(tile.x,tile.y)])
	for area in game.get_node("Bridges").get_children():
		bridges.append([area.get_position(),area.get_rotation(),area.get_shape().get_extents()])
	
	return [TerrainTiles,TransparentTiles,ObjectTiles,bridges,game.get_node("Terrain/Transparent/Objects/Marstine").get_position()]
	

# loads the map, the bridges and the player into the world
func set_game(TerrainTiles,TransparentTiles,ObjectTiles,bridges,playerPos)->void:
	for tile in TerrainTiles:
		game.get_node("Terrain").set_cell(tile[0],tile[1],tile[2])
	for tile in TransparentTiles:
		game.get_node("Terrain/Transparent").set_cell(tile[0],tile[1],tile[2])
	for tile in ObjectTiles:
		game.get_node("Terrain/Transparent/Objects").set_cell(tile[0],tile[1],tile[2])
	for bridge in bridges:
		set_bridge_area(bridge[0],bridge[1],bridge[2])
	game.get_node("Terrain/Transparent/Objects/Marstine").set_position(playerPos)
	self.add_child(game)

# creates a bridge area2d
func set_bridge_area(pos:Vector2,rot,extents:Vector2)->void:
	var area = Area2D.new()
	area.set_position(pos)
	area.set_rotation(rot)
	var rect = RectangleShape2D.new()
	rect.set_extents(extents)
	area.set_shape(rect)
	area.set_name(str(area.get_instance_id()))
	game.get_node("Bridges").add_child(area)

func remove_menu()->void:
	clean(get_node("multiplayer"))
	

func clean(node:Node):
	for nodes in node.get_children():
		if nodes.get_child_count()>0:
			clean(nodes)
	node.queue_free()

# host button 
func _on_Button3_button_up() -> void:
	#create server
	var valid = false
	
	if valid:
		# don't need to remove tiles and bridges
		game = gameLoad.instance()
		self.add_child(game)
		# notify ready to hub
		remove_menu()
	else:
		get_node("multiplayer").host_fail()
