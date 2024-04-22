extends Node2D

var json = JSON.new()
var path = "user://data.json"
var leaderboard = {}

var score = 1
var sharpshooter_combo = 0

var player_state = "free"

func write_save_file(content):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(json.stringify(content))
	file.close()
	file = null

func read_save_file():
	var file = FileAccess.open(path, FileAccess.READ)
	var content = json.parse_string(file.get_as_text())
	return content

func create_new_save_file():
	var file = FileAccess.open("res://scripts/default_leaderboard.json", FileAccess.READ)
	var content = json.parse_string(file.get_as_text())
	leaderboard = content
	write_save_file(leaderboard)
	
# Called when the node enters the scene tree for the first time.
func _ready():
	if FileAccess.file_exists(path) == false:
		create_new_save_file()
	leaderboard = read_save_file()
	
	print(leaderboard[2]["score"])
	leaderboard[2]["score"] += 100
	write_save_file(leaderboard)


func _on_timer_timeout():
	score += 1
