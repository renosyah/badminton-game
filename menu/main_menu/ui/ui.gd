extends Control

onready var label = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/Label
onready var server_browser = $CanvasLayer/Control/server_browser

# Called when the node enters the scene tree for the first time.
func _ready():
	NetworkLobbyManager.connect("on_host_player_connected", self, "_on_player_connected")
	NetworkLobbyManager.connect("on_client_player_connected", self, "_on_player_connected")
	
	OAuth2.connect("sign_out_completed", self, "_sign_out_completed")
	label.text = "Hello %s" % Global.player.player_name
	server_browser.visible = false

func _sign_out_completed():
	Global.player.delete_data(Global.player_save_file)
	get_tree().change_scene("res://menu/login/login.tscn")

func _on_sign_out_pressed():
	OAuth2.sign_out()

func _on_join_pressed():
	server_browser.visible = true
	server_browser.start_finding()

func _on_host_pressed():
	var config :NetworkServer = NetworkServer.new()
	config.max_player = 4
	
	NetworkLobbyManager.configuration = config
	NetworkLobbyManager.init_lobby()

func _on_server_browser_on_join(info):
	var config :NetworkClient = NetworkClient.new()
	config.ip = info["ip"]
	
	NetworkLobbyManager.configuration = config
	NetworkLobbyManager.init_lobby()

func _on_player_connected():
	get_tree().change_scene("res://menu/lobby/lobby.tscn")










