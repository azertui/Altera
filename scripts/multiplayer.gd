extends Control


onready var server_tree = get_node("ColorRect/ItemList")
var selected_item = null
var servers = []
var time = 0
var refreshed =false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time+=delta
	if !refreshed && time>5:
		time=0
		fill_list()

func add_server(name:String,num:int, ip:String) -> void:
	var text = "["+str(num)+"/20] "+name +" # " + ip
	server_tree.add_item(text)
	servers.append(ip)

func clear_list()->void:
	servers.clear()
	server_tree.clear()

func fill_list()->void:
	var list = get_parent().read_list_hub()
	if list.empty():
		get_parent().ask_list_hub()
	else:
		refreshed=true
		clear_list()
		for server in list:
			add_server(server[0],server[2],server[1])

func _on_Button_button_up() -> void:
# warning-ignore:return_value_discarded
	get_tree().change_scene("res://menu.tscn")

func _on_Button2_button_up() -> void:
	var selected= server_tree.get_selected_items()
	if selected.empty():
		get_node("PopupDialog2").popup()
	else:
		get_parent().connect_to(servers[selected[0]])
	
func connection_fail() -> void:
	get_node("PopupDialog").popup()
	fill_list()
	
func host_fail()->void:
	get_node("PopupDialog3").popup()

func _on_refresh_button_up() -> void:
	refreshed=false
	fill_list()
