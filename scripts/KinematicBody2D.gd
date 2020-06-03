extends KinematicBody2D

var dummy = false
var arrow = preload("res://objects/arrow.tscn")
onready var animation = get_node("AnimatedSprite")
var speed = 20
var bow_shooting = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float):
	if dummy:
		pass
	var direction = Vector2.ZERO
	var left = Input.is_action_pressed("ui_left")
	var right = Input.is_action_pressed("ui_right")
	var up = Input.is_action_pressed("ui_up")
	var down = Input.is_action_pressed("ui_down")
	
	if !down && !up && !left && !right && !bow_shooting:
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
	if Input.is_action_pressed("ui_select"):
		bow_shooting = true
		direction = Vector2.ZERO
		var anim = animation.get_animation()
		if anim == "walk_right":
			animation.play("bow_shoot_right")
		elif anim == "walk_left":
			animation.play("bow_shoot_left")
		elif anim == "walk_down":
			animation.play("bow_shoot_down")
		elif anim == "walk_up":
			animation.play("bow_shoot_up")
		elif anim == "bow_release_right":
			animation.play("bow_reshoot_right")
		elif anim == "bow_release_left":
			animation.play("bow_reshoot_left")
		elif anim == "bow_release_up":
			animation.play("bow_reshoot_up")
		elif anim == "bow_release_down":
			animation.play("bow_reshoot_down")
	elif Input.is_action_just_released("ui_select"):
		var anim = animation.get_animation()
		if anim == "bow_shoot_right" || anim == "bow_reshoot_right":
			animation.play("bow_release_right")
			var arr = arrow.instance()
			arr.init("right")
			arr.set_name(str(arr.get_instance_id()))
			get_parent().add_child(arr)
			arr.set_position(get_position())
		elif anim == "bow_shoot_left" || anim == "bow_reshoot_left":
			animation.play("bow_release_left")
			var arr = arrow.instance()
			arr.init("left")
			arr.set_name(str(arr.get_instance_id()))
			get_parent().add_child(arr)
			arr.set_position(get_position())
		elif anim == "bow_shoot_down" || anim == "bow_reshoot_down":
			animation.play("bow_release_down")
			var arr = arrow.instance()
			arr.init("down")
			arr.set_name(str(arr.get_instance_id()))
			get_parent().add_child(arr)
			arr.set_position(get_position())
		elif anim == "bow_shoot_up" || anim == "bow_reshoot_up":
			animation.play("bow_release_up")
			var arr = arrow.instance()
			arr.init("up")
			arr.set_name(str(arr.get_instance_id()))
			get_parent().add_child(arr)
			arr.set_position(get_position())
		bow_shooting=false
			
# warning-ignore:return_value_discarded
	move_and_collide(direction)
	
func change_animation(anim:String)->void:
	animation.play(anim)

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
