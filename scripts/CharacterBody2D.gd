extends CharacterBody2D

@onready var death_transition = $DeathTransition

const WorldContainer = preload("res://scripts/world_container.gd")
var wc = null

var scorescreen = load("res://scenes/Gamestates/scorescene.tscn")
const SPEED = 60

func _ready():
	if wc == null:
		var tile_map = get_parent().get_parent().get_node("TileMap")
		wc = WorldContainer.new(tile_map)
		
	wc.generate_env(position.x, position.y)

func _physics_process(delta):
	if (GameMaster.player_state == "game_over"):
		return

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
	GameMaster.player_state = "game_over"
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	death_transition.play("fade_out")
	tween.tween_property($Sprite2D, "scale", Vector2(0,0), 0.2)

func _input(event):
	if event.is_action_pressed("interact"):
		wc.generate_env(position.x, position.y)

func game_over():
	GameMaster.player_state = "game_over"
	var tween = create_tween().set_trans(Tween.TRANS_SINE)
	death_transition.play("fade_out")
	tween.tween_property($Sprite2D, "modulate", Color(255, 255, 255, 0), 0.2)


func _on_death_transition_animation_finished(anim_name):
	get_tree().change_scene_to_packed(scorescreen)
