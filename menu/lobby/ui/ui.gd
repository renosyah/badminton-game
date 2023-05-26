extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_disconnected", self, "_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "_disconnected")

func _disconnected():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")

func _on_back_pressed():
	Network.disconnect_from_server()
