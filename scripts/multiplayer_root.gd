extends Node

# message types:
# TO_HUB
# 1 => server update or timeout reply
# 2 => server closed
# 3 => list request
# 4 => server creation request
# 5 => server created
# FROM_HUB
# 1 server list message
# 2 timeout request
# 3 server approval
# 4 server disapproval
# 5 server added

const PORT_CLIENT=6744
const PORT_HUB=6745
const HUB_IP="34.78.149.4"
var socketUDP = PacketPeerUDP.new()
var gameLoad = preload("res://game.tscn")
var game = null
var maxTimeOut
const maxTimeOuts = 10
var Bname
var hosting = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	init_udp_hub()
	ask_list_hub()
func _exit_tree()->void:
	if hosting:
		var paquet = PoolByteArray()
		paquet.append(2)
		paquet.append(Bname.size())
		paquet.append_array(Bname)
		socketUDP.put_packet(paquet)
	socketUDP.close()

func init_udp_hub()->void:
	if (socketUDP.listen(PORT_CLIENT) != OK):
		print("Error listening on port: " + str(PORT_CLIENT))
	else:
		print("Listening on port: " + str(PORT_CLIENT))
	socketUDP.set_dest_address(HUB_IP,PORT_HUB)

func ask_list_hub()->void:
	print("asked list to hub")
	var pac = PoolByteArray()
	pac.append(3)
	socketUDP.put_packet(pac)
# creates an empty game instance
func read_list_hub()->Array:
	# flushes packets to only read the last one
	var pac=PoolByteArray()
	while socketUDP.get_available_packet_count()>0:
		var tmp=socketUDP.get_packet()
		print("got packet with type "+str(tmp[0])+ " from " + socketUDP.get_packet_ip() + ":" +str(socketUDP.get_packet_port()))
		# must be a list type packet from hub
		if tmp[0]==1 && socketUDP.get_packet_ip()==HUB_IP:
			pac = tmp
	if pac.empty():
		print("no replies from hub")
		return []
	var list = []
	printt("Got a reply! decoding...")
	printt(pac.get_string_from_ascii())
	pac=pac.subarray(1,pac.size()-1)
	printt(pac.get_string_from_ascii())
	while pac[0]!=70:
		print("name size ="+str(pac[0]))
		var name = (pac.subarray(1,pac[0])).get_string_from_ascii()
		print(name)
		print("ip size ="+str(pac[1+pac[0]]))
		var ip = (pac.subarray(2+pac[0],pac[1+pac[0]]+pac[0]+1)).get_string_from_ascii()
		print(ip)
		var num = pac[2+pac[0]+pac[1+pac[0]]]
		print(str(num))
		list.append([name,ip,num])
		pac = pac.subarray(pac[0]+pac[1+pac[0]]+3,pac.size()-1)
	printt("decoded!")
	return list

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
	clean(get_node("Timer"))
	clean(get_node("PopupDialog"))
	clean(get_node("Control"))
	

func clean(node:Node):
	for nodes in node.get_children():
		if nodes.get_child_count()>0:
			clean(nodes)
	node.queue_free()

# host button 
func _on_Button3_button_up() -> void:
	get_node("PopupDialog").popup()


func _on_LineEdit_text_entered(new_text: String) -> void:
	get_node("PopupDialog").hide()
	var name = get_node("PopupDialog/LineEdit").get_text()
	get_node("multiplayer").hide()
	get_node("Control").show()
	get_node("Control/AnimatedSprite").play()
	var paquet = PoolByteArray()
	paquet.append(4)
	Bname = name.to_ascii()
	paquet.append(Bname.size())
	paquet.append_array(Bname)
	socketUDP.put_packet(paquet)
	maxTimeOut=maxTimeOuts
	get_node("Timer").start(1)


func _on_Timer_timeout() -> void:
	var approved = false
	var paquet
	while socketUDP.get_available_packet_count()>0:
		paquet=socketUDP.get_packet()
		print("got packet of type "+str(paquet[0]))
		if paquet[0]==4:
			maxTimeOut=0
		elif paquet[0]==5:
			approved=true
			break
		elif paquet[0]==3:
			game = gameLoad.instance()
			var pac = PoolByteArray()
			pac.append(5)
			pac.append(Bname.size())
			pac.append_array(Bname)
			pac.append(1)
			socketUDP.put_packet(pac)
	if !approved && maxTimeOut>0:
		maxTimeOut=maxTimeOut-1
		get_node("Timer").start(1)
	elif approved:
		hosting = true
		self.add_child(game)
		remove_menu()
	else:
		if game!=null:
			game.queue_free()
			game=null
		get_node("multiplayer").show()
		get_node("Control").hide()
		get_node("Control/AnimatedSprite").stop()
		get_node("multiplayer").host_fail()
