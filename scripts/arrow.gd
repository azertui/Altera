extends KinematicBody2D

var speed = 100
var TTL=10
var dir = Vector2.ZERO
var n_arrows = 10
var from_player
var touch = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var arrows =get_tree().get_nodes_in_group("arrows")
	if arrows.size()>n_arrows:
		arrows.front().queue_free()
	pass # Replace with function body.

func init(direction:String, player=true) -> void:
	from_player=player
	if direction == "left":
		rotate(PI)
		dir.x=-speed
	elif direction == "up":
		rotate(-PI/2)
		dir.y=-speed
	elif direction == "down":
		rotate(PI/2)
		dir.y=speed
	else:
		dir.x=speed
	#else right

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !touch:
		var test = move_and_collide(dir*delta)
		if test is KinematicCollision2D && test.collider is Node:
			for group in test.collider.get_groups():
				if group == "arrows" || (group == "player" && from_player):
					add_collision_exception_with(test.collider)
					move_and_slide(dir*delta)
					touch = false
					break
				else:
					touch = true
		elif test is CollisionShape2D:
			print("shape")
		elif test is CollisionPolygon2D:
			print("poly")
