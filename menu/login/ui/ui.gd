extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	OAuth2.connect("sign_in_completed", self, "_sign_in_completed")
	OAuth2.connect("profile_info", self , "_profile_info")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	get_tree().quit()
	
func _sign_in_completed():
	OAuth2.get_profile_info()
	
func _profile_info(profile :OAuth2.OAuth2UserInfo):
	Global.player.player_id = profile.id
	Global.player.player_name = profile.given_name
	Global.player.player_avatar = profile.picture
	Global.player.save_data(Global.player_save_file)
	
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
func _on_sign_in_button_pressed():
	OAuth2.sign_in()
