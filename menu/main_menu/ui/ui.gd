extends Control

onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	OAuth2.connect("sign_out_completed", self, "_sign_out_completed")
	label.text = Global.player.player_name

func _sign_out_completed():
	Global.player.delete_data(Global.player_save_file)
	get_tree().change_scene("res://menu/login/login.tscn")

func _on_sign_out_pressed():
	OAuth2.sign_out()
