extends KinematicBody2D


# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"
onready var animation = get_node("AnimatedSprite")
var speed = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_safe_margin(0.001)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	var direction: Vector2
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	if !down && !up && !left && !right:
		animation.stop()
		animation.set_frame(0)
	else:
		if up && down:
			var anim = animation.get_animation()
			if anim == "walk_down" || anim == "walk_up":
				animation.stop()
			up=false
			down=false
		elif up:
			animation.play("walk_up")
			direction.y=-speed*delta
		elif down:
			animation.play("walk_down")		
			direction.y=speed*delta
		else:
			var anim = animation.get_animation()
			if anim == "walk_up" || anim == "walk_down":
				animation.stop()
		if right && left:
			var anim = animation.get_animation()
			if anim == "walk_left" || anim =="walk_right":
				animation.stop()
		elif right:
			if !up && !down:
				animation.play("walk_right")
			direction.x=speed*delta
		elif left:
			if !up && !down:
				animation.play("walk_left")
			direction.x=-speed*delta
		else:
			var anim = animation.get_animation()
			if anim == "walk_right" || anim == "walk_left":
				animation.stop()
		if Input.is_action_pressed("ui_shift"):
			direction*=2
			animation.set_speed_scale(2)
		else:
			animation.set_speed_scale(1)
		move_and_collide(direction)
	


func _on_Bridges_body_entered(body: Node) -> void:
	if body.get_instance_id()==get_instance_id():
		set_collision_layer_bit(0,false)
		set_collision_mask_bit(0,false)
	print("enter: "+body.get_name())


func _on_Bridges_body_exited(body: Node) -> void:
	if body.get_instance_id()==get_instance_id():
		set_collision_layer_bit(0,true)
		set_collision_mask_bit(0,true)
	print("exit: "+body.get_name())
