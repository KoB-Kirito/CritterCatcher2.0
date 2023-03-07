extends MarginContainer


var value: int
var player: Player

@onready var text = %Text


func _ready():
	player = get_tree().get_first_node_in_group("player")
	text.text = str(value)


func _process(_delta):
	if value < player.score:
		value = player.score
		queue_redraw()


func _draw():
	text.text = str(value) + " / 5"
