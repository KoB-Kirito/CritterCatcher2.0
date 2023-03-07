extends Node


func _process(_delta):
	if Input.is_action_just_released("back") or Input.is_action_just_released("start"):
		get_tree().change_scene_to_packed(load("res://scenes/menu/start_screen.tscn"))
