extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_disconnected", self, "_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "_disconnected")
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			_on_back_pressed()
			return
		
func _disconnected():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")

func _on_back_pressed():
	Network.disconnect_from_server()
