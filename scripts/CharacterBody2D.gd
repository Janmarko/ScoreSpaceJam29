extends CharacterBody2D

const WorldContainer = preload("res://scripts/world_container.gd")
var wc = null

const SPEED = 75.0

func _ready():
	if wc == null:
		var tile_map = get_parent().get_parent().get_node("TileMap")
		wc = WorldContainer.new(tile_map)
		
	wc.generate_env(position.x, position.y)

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("move_left", "move_right")
	var direction_y = Input.get_axis("move_up", "move_down")
	if direction_x || direction_y:
		velocity.x = direction_x * SPEED
		velocity.y = direction_y * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()

func get_squished():
	print("lmao, bucko, you just got squished")

func _input(event):
	if event.is_action_pressed("interact"):
		wc.generate_env(position.x, position.y)
