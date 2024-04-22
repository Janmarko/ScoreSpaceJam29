extends VBoxContainer

var scores = [0, 0, 0, 0, 0]
# Called when the node enters the scene tree for the first time.
func _ready():
	
	load_highscores()
	scores.sort()
	save_highscores()
	GameMaster.write_save_file(GameMaster.leaderboard)

func load_highscores():
	for i in 5:
		scores[i] = GameMaster.leaderboard[i]["score"]
		print("hemnlo " + str(scores[i]))

func save_highscores():
	for i in 5:
		get_child(i).text = "Rank " + str(i + 1) + ": " + str(scores[4-i])
		GameMaster.leaderboard[i]["score"] = scores[4-i]
