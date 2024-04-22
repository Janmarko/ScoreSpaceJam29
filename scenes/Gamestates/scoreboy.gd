extends Label
var score_chaser = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	text = "0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (score_chaser < GameMaster.score - 7):
		score_chaser += GameMaster.score / score_chaser * 7
	else:
		score_chaser = GameMaster.score
	text = str(score_chaser)
