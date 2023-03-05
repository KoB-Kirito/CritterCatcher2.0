class_name Player
extends CharacterBody2D

const GRAVITY = 50.0
const DRAG = 10.0
const MAX_VELOCITY = 150.0

var thrust = 100.0

var stun_time = 0.0
var stun_dir: Vector2

@onready var sprite = %Sprite2D
var x_direction

@export var net: PackedScene
@export var light: ColorRect

var net_reload_timer = 0.0;
const NET_RELOAD_REF = 2.0;

func _process(delta):
	net_reload_timer -= delta
	stun_time -= delta

	light.material.set_shader_parameter("ar", get_viewport_rect().size.y / get_viewport_rect().size.x)
	light.material.set_shader_parameter("position", Vector2.ONE / 2)

	if x_direction == null:
		return

	if sprite.flip_h and x_direction > 0:
		sprite.flip_h = false
	elif (not sprite.flip_h) and x_direction < 0:
		sprite.flip_h = true

	if Input.is_action_just_pressed("fire") and net_reload_timer <= 0.0:
		var go = net.instantiate()
		get_parent().add_child(go)
		go.position = position
		var x = -1 if sprite.flip_h else 1
		(go as RigidBody2D).add_constant_central_force(Vector2(3 * x, -1).normalized() * 350)
		(go.get_node("Sprite2D") as Sprite2D).flip_h = x
		net_reload_timer = NET_RELOAD_REF


func _physics_process(delta):
	# add gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if stun_time <= 0.0:
		# add thrust
		var y_direction = Input.get_axis("move_up", "move_down")
		if y_direction:
			if (y_direction < 0 && velocity.y > 0) || (y_direction > 0 && velocity.y < 0):
				y_direction *= 2
			velocity.y += y_direction * thrust * delta
			
		else:
			velocity.y = move_toward(velocity.y, 0, DRAG * delta)
		
		x_direction = Input.get_axis("move_left", "move_right")
		if x_direction:
			if (x_direction < 0 && velocity.x > 0) || (x_direction > 0 && velocity.x < 0):
				x_direction *= 2
			velocity.x += x_direction * thrust * delta
			
		else:
			velocity.x = move_toward(velocity.x, 0, DRAG * delta)
	else:
		velocity = stun_dir * delta * 10000.0

	# clamp velocity
	velocity = velocity.clamp(Vector2(-MAX_VELOCITY, -MAX_VELOCITY), Vector2(MAX_VELOCITY, MAX_VELOCITY))

	move_and_slide()
	var coll = move_and_collide(velocity * delta, true)
	if coll != null:
		bump(coll.get_normal())

func bump(normal: Vector2):
	stun_time = 1.0
	stun_dir = normal.normalized()
