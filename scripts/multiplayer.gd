extends Control


onready var server_tree = get_node("ColorRect/ItemList")
var selected_item = null
var servers = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_server("test1",1, "127.0.0.1")
	add_server("test2",2, "255.255.255.255")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func add_server(name:String,num:int, ip:String) -> void:
	var text = "["+str(num)+"/20] "+name +" # " + ip
	server_tree.add_item(text)
	servers.append(ip)

func refresh_list()->void:
	servers.clear()
	server_tree.clear()

func _on_Button_button_up() -> void:
	get_tree().change_scene("res://menu.tscn")


func _on_Button2_button_up() -> void:
	var selected= server_tree.get_selected_items()[0]
	print(servers[selected])


func _on_refresh_button_up() -> void:
	refresh_list()
