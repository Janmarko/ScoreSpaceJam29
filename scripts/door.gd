extends Node2D
var is_open = false
var is_moving = false
@onready var door1 = get_node("door1")
@onready var door2 = get_node("door2")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func door_open():
	is_moving = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(door1, "position", Vector2(0, 24), 2)
	tween.tween_property(door2, "position", Vector2(0, -24), 2)
	await tween.finished
	is_open = true
	is_moving = false
	
func door_close():
	is_moving = true
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(door1, "position", Vector2(0, 8), 2)
	tween.tween_property(door2, "position", Vector2(0, -8), 2)
	await tween.finished
	is_open = false
	is_moving = false

func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if is_moving == false:
				if is_open == true:
					print("close it!")
					door_close()
				else:
					print("open it")
					door_open()
