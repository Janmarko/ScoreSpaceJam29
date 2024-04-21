extends Area2D
class_name InteractionArea


@export var action_name: String = "interact"

var interact: Callable = func():
	pass
	
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	print("welcome")
	InteractionManager.register_area(self)

func _on_body_exited(body):
	print("goodbye")
	InteractionManager.unregister_area(self)
