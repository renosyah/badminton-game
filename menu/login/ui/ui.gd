extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	OAuth2.connect("sign_in_completed", self, "_sign_in_completed")
	OAuth2.connect("profile_info", self , "_profile_info")
	
func _sign_in_completed():
	OAuth2.get_profile_info()
	
func _profile_info(profile :OAuth2.OAuth2UserInfo):
	Global.player.player_id = profile.id
	Global.player.player_name = profile.given_name
	Global.player.player_color = Color(randf(), randf(), randf(), 1)
	Global.player.player_team = 1
	Global.player.player_avatar = profile.picture
	Global.player.save_data(Global.player_save_file)
	
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
func _on_sign_in_button_pressed():
	OAuth2.sign_in()
