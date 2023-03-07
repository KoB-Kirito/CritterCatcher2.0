class_name Player
extends RigidBody2D
# player controlled character


const THRUST = 10.0
const MAX_VELOCITY = 150.0
const DRAG = 2.0

@export var starting_health: int = 5

# values read by hud
var health: int = starting_health
var pressure: float
var score: int

var previous_velocity = Vector2.ZERO
var original_position: Vector2
var x_direction: float
var broken = false

@onready var sprite = %Sprite2D
@onready var sprite_broken = %BrokenSprite
@onready var snd_bump = %snd_bump
@onready var snd_damage = %snd_damage
@onready var harpoon_launcher := %HarpoonLauncher as HarpoonLauncher
@onready var invincible_timer = %InvincibleTimer


func _ready():
	original_position = global_position

func _process(_delta):
	if Input.is_action_just_pressed("reset"):
		global_position = original_position
		linear_velocity = Vector2.ZERO
		broken = false
		health = starting_health
		#score = 0
		#todo: reset fishes
		sprite_broken.visible = false
		sprite.visible = true
	
	if broken:
		return
	
	# pressure = depth?
	pressure = (position.y + 900.0) * 100.0 / 4800.0
	
	# animation
	if Input.is_action_pressed("move_down") \
			or Input.is_action_pressed("move_left") \
			or Input.is_action_pressed("move_right") \
			or Input.is_action_pressed("move_up"):
		if sprite.frame == 0 or sprite.frame == 2:
			sprite.frame = 1
			
	else:
		if sprite.frame == 1 or sprite.frame == 3:
			sprite.frame = 0
	
	# harpoon animation
	if sprite.frame < 2 and not harpoon_launcher.harpoon_ready:
		sprite.frame += 2
	elif sprite.frame >= 2 and harpoon_launcher.harpoon_ready:
		sprite.frame -= 2
	
	if x_direction == null:
		return
	
	if sprite.flip_h and x_direction > 0:
		sprite.flip_h = false
	elif (not sprite.flip_h) and x_direction < 0:
		sprite.flip_h = true


func _integrate_forces(state):
	if broken:
		return
	
	var velocity = Vector2.ZERO

	# add THRUST
	var y_direction = Input.get_axis("move_up", "move_down")
	if y_direction:
		if (y_direction < 0 && velocity.y > 0) || (y_direction > 0 && velocity.y < 0):
			y_direction *= 2
		velocity.y += y_direction * THRUST
	else:
		linear_velocity.y = move_toward(linear_velocity.y, 0, DRAG)

	x_direction = Input.get_axis("move_left", "move_right")
	if x_direction:
		if (x_direction < 0 && velocity.x > 0) || (x_direction > 0 && velocity.x < 0):
			x_direction *= 2
		velocity.x += x_direction * THRUST
	else:
		linear_velocity.x = move_toward(linear_velocity.x, 0, DRAG)

	linear_velocity += velocity
	
	# clamp velocity
	linear_velocity = linear_velocity.clamp(Vector2(-MAX_VELOCITY, -MAX_VELOCITY), Vector2(MAX_VELOCITY, MAX_VELOCITY))

	if(state.get_contact_count() >= 1):
		if state.get_contact_collider_object(0).name.begins_with("Fish"):
			snd_damage.play()
			var fish = (state.get_contact_collider_object(0) as Fish)
			if fish.can_collect():
				fish.queue_free()
				add_score()
				
			else:
				var p = (position - fish.position).normalized() * 1000.0
				linear_velocity += p / 20
				fish.propulse(-p / 5)
				# take damage if colliding with fish?
				if fish.does_damage():
					take_damage(1)
		else:
			snd_bump.play()

	previous_velocity = linear_velocity


func take_damage(amount: int):
	if not invincible_timer.is_stopped():
		return
	
	invincible_timer.start()
	
	health -= amount
	if health == 0:
		broken = true
		sprite_broken.visible = true
		sprite.visible = false


func add_score():
	score += 1
	if score >= 5:
		get_tree().change_scene_to_packed(load("res://scenes/menu/start_screen.tscn"))
		#todo: victory scene
