extends Sprite2D

@onready var path = get_parent()
@onready var laser_manager = get_parent().get_parent().get_parent().get_parent().get_child(1)
@onready var laser = preload("res://scenes/player/laser.tscn")

var laser_speed = 500

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path.progress_ratio = (global_position.x - get_global_mouse_position().x) / -100 + 0.5
	if Input.is_action_just_pressed("interact"):
		if GameMaster.player_state == "free":
			shoot_laser()

func shoot_laser():
	var laser_instance = laser.instantiate()
	laser_manager.add_child(laser_instance)
	laser_instance.global_position = global_position
	print(global_position.direction_to(get_global_mouse_position()) * laser_speed)
	laser_instance.velocity = global_position.direction_to(get_global_mouse_position()) * laser_speed
	
