extends Control

onready var time_left = $VBoxContainer/time_left
onready var score_team__1 = $VBoxContainer/HBoxContainer2/score_team_1
onready var score_team__2 = $VBoxContainer/HBoxContainer2/score_team_2
onready var animation_player = $AnimationPlayer

onready var bang_1 = $bang/bang1
onready var bang_2 = $bang/bang2
onready var bang_3 = $bang/bang3

func show_time_left(time_remaining :int):
	time_left.text = str(time_remaining)

func show_score(team_1_score, team_2_score :int):
	score_team__1.text = str(team_1_score)
	score_team__2.text = str(team_2_score)

func show_bang(type_bang :int):
	bang_1.visible = false
	bang_2.visible = false
	bang_3.visible = false
	
	match (type_bang):
		1:
			bang_1.visible = true
		2:
			bang_2.visible = true
		3:
			bang_3.visible = true
			
	animation_player.play("out")
	yield(animation_player,"animation_finished")
	
	bang_1.visible = false
	bang_2.visible = false
	bang_3.visible = false
	
	animation_player.play("RESET")
