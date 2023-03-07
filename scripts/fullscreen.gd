extends Node

var fullscreen: bool = false

func _process(_delta):
	if Input.is_action_just_pressed("fullscreen"):
		if not fullscreen:
			fullscreen = true
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			fullscreen = false
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
