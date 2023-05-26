extends Control

func _ready():
	OAuth2.connect("sign_in_completed", self, "_sign_in_completed")
	OAuth2.connect("sign_in_expired", self, "_sign_in_expired_or_no_session")
	OAuth2.connect("no_session", self, "_sign_in_expired_or_no_session")
	
	Admob.connect("initialization_finish", self,"_initialization_finish")
	Admob.initialize()
	
func _initialization_finish():
	if Global.has_login:
		_sign_in_completed()
		return
		
	OAuth2.check_sign_in_status()

func _sign_in_completed():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
func _sign_in_expired_or_no_session():
	get_tree().change_scene("res://menu/login/login.tscn")
