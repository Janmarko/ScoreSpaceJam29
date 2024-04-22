extends CharacterBody2D

@onready var navigation_agent = $NavigationAgent2D as NavigationAgent2D

var speed = 25.0
const ACCELERATION = 10
const HIT_SCORE = 100
var max_health = 5
var hitstun_time = 0.1
var health
var hitstun = false
var player = null
var is_chasing = false

func _ready():
	health = max_health

func _physics_process(delta):
	if hitstun == true:
		return
	if is_chasing == false:
		$Pathfind_timer.stop()
		return
	
	var direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = velocity.lerp(direction * speed, ACCELERATION * delta)
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()

func _on_area_2d_body_entered(body):
	player = body
	print("there you are!")
	is_chasing = true
	$Pathfind_timer.start()

func _on_area_2d_body_exited(body):
	player = null
	print("bye!")
	is_chasing = false

func _on_pathfind_timer_timeout():
	make_path()
		
func make_path():
	if is_chasing == true:
		speed = 55
		navigation_agent.target_position = player.global_position
	else:
		speed = 20
		navigation_agent.target_position = global_position + Vector2(randi_range(-64, 64), randi_range(-64, 64))
		#if navigation_agent.target_position.x > position.x:
			#$AnimatedSprite2D.flip_h = true
		#else:
			#$AnimatedSprite2D.flip_h = false

func take_damage(amount):
	
	GameMaster.score += HIT_SCORE + GameMaster.sharpshooter_combo * 10
	print(GameMaster.score)
	
	if health < 1:
		queue_free()
	
	health -= amount
	hitstun = true
	$AnimatedSprite2D.modulate = Color.DARK_RED
	await get_tree().create_timer(hitstun_time).timeout
	$AnimatedSprite2D.modulate = Color.WHITE
	hitstun = false

func get_squished():
	GameMaster.score += HIT_SCORE * 10
	print("noooo I'm squished!!")
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property($AnimatedSprite2D, "scale", Vector2(0, 0), 0.1)
	await tween.finished
	queue_free()

func _on_hurtbox_area_body_entered(body):
	if body.has_method("game_over"):
		body.game_over()



	
