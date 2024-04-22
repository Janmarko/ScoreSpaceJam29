extends Area2D

var velocity = Vector2()
var damage = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += velocity * delta

func _on_body_entered(body):
	if body.has_method("game_over"):
		body.game_over()
	queue_free()
