extends Camera2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var target = get_parent().get_node("CanvasLayer/KinematicBody2D")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float):
	var pos = target.get_position()
	set_position(pos)
#	pass
