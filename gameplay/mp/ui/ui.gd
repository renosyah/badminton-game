extends Control
class_name UiMp

onready var joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/joystick
onready var score = $CanvasLayer/Control/SafeArea/VBoxContainer/score

var team_1_score :int = 0
var team_2_score : int = 0

func get_move_direction() -> Vector3:
	var output = joystick.get_output()
	return Vector3(output.x, 0, output.y).normalized()

func add_score(team :int):
	if team == 1:
		team_1_score += 1
		
	elif team == 2:
		team_2_score += 1
		
	score.text = "Team 1 : %s - Team 2 : %s" % [team_1_score, team_2_score]
