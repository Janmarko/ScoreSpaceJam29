extends CharacterBody2D

@onready var navigation_agent = $NavigationAgent2D as NavigationAgent2D
@onready var laser_manager = get_parent().get_parent().get_child(1)
@onready var spit_target = get_parent().get_parent().get_child(0)
@onready var spit = preload("res://scenes/player/spit.tscn")

const SPEED = 30.0
const ACCELERATION = 10
const HIT_SCORE = 100
var max_health = 5
var hitstun_time = 0.1
var health
var hitstun = false
var player = null
var is_chasing = false
var spit_speed = 500

func _ready():
	health = max_health

func _physics_process(delta):
	if hitstun == true:
		return
	var direction = to_local(navigation_agent.get_next_path_position()).normalized()
	velocity = velocity.lerp(direction * SPEED, ACCELERATION * delta)
	
	if velocity.x > 0:
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	if is_chasing == true:
		move_and_slide()

func _on_area_2d_body_entered(body):
	player = body
	print("there you are!")
	is_chasing = true

func _on_area_2d_body_exited(body):
	player = null
	print("bye!")
	is_chasing = false

func _on_pathfind_timer_timeout():
	var rando = randi_range(0, 100)
	if rando < 8:
		is_chasing = false
		shoot_spit()
		
	if is_chasing == true:
		make_path()
		
func make_path():
		navigation_agent.target_position = player.global_position

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

func shoot_spit():
	$AnimatedSprite2D.animation = "spit"
	
	var spit_instance = spit.instantiate()
	laser_manager.add_child(spit_instance)
	spit_instance.self_modulate = Color.GREEN_YELLOW
	spit_instance.global_position = global_position
	spit_instance.velocity = global_position.direction_to(spit_target.global_position) * spit_speed


func _on_animated_sprite_2d_animation_finished():
	var spit_instance = spit.instantiate()
	laser_manager.add_child(spit_instance)
	spit_instance.self_modulate = Color.GREEN_YELLOW
	spit_instance.global_position = global_position
	spit_instance.velocity = global_position.direction_to(spit_target.global_position) * spit_speed
	$AnimatedSprite2D.animation = "walk"
