extends Node2D
var is_open = false
var is_moving = false
var is_vertical = false
@onready var door1 = get_node("door1")
@onready var door2 = get_node("door2")

# Called when the node enters the scene tree for the first time.
func _ready():
	if is_vertical == true:
		rotation = 0
	else:
		rotation = PI/2
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func door_open():
	is_moving = true
	var tween1 = create_tween().set_trans(Tween.TRANS_SINE)
	tween1.set_parallel(true)
	tween1.tween_property(door1, "position", Vector2(0, 6), 1.2)
	tween1.tween_property(door2, "position", Vector2(0, -6), 1.2)
	await tween1.finished
	var tween2 = create_tween().set_trans(Tween.TRANS_SINE)
	tween2.set_parallel(true)
	tween2.tween_property(door1, "position", Vector2(0, 12), 0.2)
	tween2.tween_property(door2, "position", Vector2(0, -12), 0.2)
	await tween2.finished
	is_open = true
	is_moving = false
	
func door_close():
	is_moving = true
	var tween1 = create_tween().set_trans(Tween.TRANS_SINE)
	tween1.set_parallel(true)
	tween1.tween_property(door1, "position", Vector2(0, 10), 1.2)
	tween1.tween_property(door2, "position", Vector2(0, -10), 1.2)
	await tween1.finished
	
	$hurtbox.monitoring = true
	
	var tween2 = create_tween().set_trans(Tween.TRANS_SINE)
	tween2.set_parallel(true)
	tween2.tween_property(door1, "position", Vector2(0, 4), 0.2)
	tween2.tween_property(door2, "position", Vector2(0, -4), 0.2)
	await tween2.finished
	
	$hurtbox.monitoring = false
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

func _on_hurtbox_body_entered(body):
	if body.has_method("get_squished"):
		body.get_squished()
