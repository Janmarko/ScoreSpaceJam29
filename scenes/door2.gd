extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func take_damage(amount):
	if get_parent().is_open == false:
		get_parent().is_open = true
		get_parent().door_open()
		await get_tree().create_timer(15).timeout
		get_parent().door_close()
		get_parent().is_open = false
