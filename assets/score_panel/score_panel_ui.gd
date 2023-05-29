extends Control

onready var time_left = $VBoxContainer/time_left
onready var score_team__1 = $VBoxContainer/HBoxContainer2/score_team_1
onready var score_team__2 = $VBoxContainer/HBoxContainer2/score_team_2
onready var animation_player = $AnimationPlayer

func show_time_left(time_remaining :int):
	time_left.text = str(time_remaining)

func show_score(team_1_score, team_2_score :int):
	score_team__1.text = str(team_1_score)
	score_team__2.text = str(team_2_score)

func show_out():
	animation_player.play("out")
	yield(animation_player,"animation_finished")
	animation_player.play("RESET")
