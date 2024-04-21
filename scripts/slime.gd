extends CharacterBody2D


const SPEED = 20.0
const JUMP_VELOCITY = -400.0
var player = null
var is_chasing = false
#const chase_offset = Vector2(0, 8)


func _physics_process(delta):
	if is_chasing == true:
		velocity = position.direction_to(player.position) * SPEED
		move_and_slide()

func _on_area_2d_body_entered(body):
	player = body
	is_chasing = true

func _on_area_2d_body_exited(body):
	player = null
	is_chasing = false
