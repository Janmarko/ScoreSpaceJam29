extends Area2D


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameMaster.player_state == "hacking" and get_parent().is_moving == false:
		show()
	else:
		hide()
	
