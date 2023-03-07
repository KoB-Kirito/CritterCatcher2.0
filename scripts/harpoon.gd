class_name Harpoon
extends Area2D


@export var speed: float = 200.0

var direction: float

@onready var sprite = %Sprite2D


func _ready():
	if direction < 0:
		sprite.flip_h = true


func _physics_process(delta):
	position.x += direction * speed * delta


func _on_body_entered(body):
	if body.name.begins_with("Player"):
		return
	
	if body.name.begins_with("Fish"):
		(body as Fish).get_hit()
	queue_free()


func _on_lifetime_timer_timeout():
	queue_free()
