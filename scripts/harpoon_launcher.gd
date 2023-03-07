class_name HarpoonLauncher
extends Node2D
# instantiates and rotates


@export var projectileScene: PackedScene

var harpoon_ready: bool = true

@onready var parent = get_parent()
@onready var snd_shoot = %snd_shoot as AudioStreamPlayer2D
@onready var cooldown_timer = %CooldownTimer as Timer


func _process(_delta):
	# don't shoot if on cooldown
	if not cooldown_timer.is_stopped():
		return
	
	if Input.is_action_just_pressed("fire"):
		harpoon_ready = false
		cooldown_timer.start()
		snd_shoot.play()
		
		# initialize
		var projectile := projectileScene.instantiate() as Harpoon
		
		# set values
		var direction: float = -1 if parent.sprite.flip_h else 1
		projectile.direction = direction
		
		# spawn on level
		get_parent().get_parent().add_child(projectile)
		
		# set start position
		projectile.global_position = global_position
		projectile.position.x += 22 * direction
		projectile.position.y += -6


func _on_cooldown_timer_timeout():
	harpoon_ready = true
