extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	GameMaster.score = 1
	GameMaster.sharpshooter_combo = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("interact"):
		worldgen()

func generate_tiles():
	pass

func worldgen():
	pass
