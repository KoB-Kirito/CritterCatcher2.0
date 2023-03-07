extends Node


func _process(_delta):
	if Input.is_action_just_released("back"):
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		#get_tree().quit() on desktop
	
	# start with controller
	if Input.is_action_just_released("start"):
		get_parent()._on_button_pressed()
