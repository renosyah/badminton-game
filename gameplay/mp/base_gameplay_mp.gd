extends Node
class_name BaseGameplayMp

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	
	setup_enviroment()
	setup_camera()
	setup_arena()
	setup_shuttlecocks()
	setup_ui()
	
func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			on_back_pressed()
			return
			
		MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
			on_back_pressed()
			return
		
func on_back_pressed():
	on_exit_game_session()
	
################################################################
# shuttlecock

var shuttlecocks :Array = []

func setup_shuttlecocks():
	var shuttlecock_scnene = preload("res://entity/projectile/shuttlecock/shuttlecock.tscn")
	
	for i in 4:
		var shuttlecock = shuttlecock_scnene.instance()
		shuttlecock.name = "shuttlecock_%s" % i
		shuttlecock.set_network_master(Network.PLAYER_HOST_ID)
		shuttlecock.connect("land", self, "_on_shuttlecock_land")
		add_child(shuttlecock)
		
		shuttlecock.translation.z = 20
		shuttlecock.speed = rand_range(24, 45)
		shuttlecock.target = Vector3(shuttlecock.translation.x, 4, -shuttlecock.translation.z)
		shuttlecock.launch()
		
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	_shuttlecock.target.z = -_shuttlecock.target.z
	_shuttlecock.target.x = rand_range(-20, 20)
	_shuttlecock.launch()
	
################################################################
# arena
var _arena :Arena

func setup_arena():
	_arena = preload("res://map/arena.tscn").instance()
	_arena.connect("on_projectile_enter_area", self, "_on_projectile_enter_area")
	_arena.connect("on_projectile_exit_area", self, "_on_projectile_exit_area")
	add_child(_arena)
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	print("projectile enter on %s" % area)
	
func _on_projectile_exit_area(projectile :BaseProjectile, area :int):
	print("projectile exit %s" % area)
	
################################################################
# team cameras

var _camera_team_1 :FixCamera
var _camera_team_2 :FixCamera

func setup_camera():
	var camera_scene = preload("res://assets/fix_camera/fix_camera.tscn")
	
	_camera_team_1 = camera_scene.instance()
	add_child(_camera_team_1)
	_camera_team_1.translation.z = 60
	_camera_team_1.translation.y = 45
	
	_camera_team_2 = camera_scene.instance()
	add_child(_camera_team_2)
	_camera_team_2.translation.z = -60
	_camera_team_2.translation.y = 45
	_camera_team_2.rotation_degrees.y = 180
	
	_camera_team_1.camera.current = true
	
################################################################
# directional light
var _environment :Node

func setup_enviroment():
	_environment = preload("res://assets/enviroment/enviroment.tscn").instance()
	add_child(_environment)
	
################################################################
# ui
var _ui :Control

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	add_child(_ui)
	
################################################################
# network connection watcher
# for both client and host
func init_connection_watcher():
	NetworkLobbyManager.connect("on_host_disconnected", self, "on_host_disconnected")
	NetworkLobbyManager.connect("connection_closed", self, "connection_closed")
	NetworkLobbyManager.connect("all_player_ready", self, "all_player_ready")
	NetworkLobbyManager.connect("on_player_disconnected", self, "on_player_disconnected")
	
func on_player_disconnected(_player_network :NetworkPlayer):
	pass
	
func connection_closed():
	to_main_menu()
	
func on_host_disconnected():
	to_main_menu()
	
func all_player_ready():
	pass
	
################################################################
# exit
func on_exit_game_session():
	Network.disconnect_from_server()
	
func to_main_menu():
	get_tree().change_scene("res://menu/main_menu/main_menu.tscn")
	
################################################################
# network utils code
func is_server():
	if not is_network_on():
		return false
		
	if not get_tree().is_network_server():
		return false
		
	return true
	
func is_network_on() -> bool:
	if not get_tree().network_peer:
		return false
		
	if get_tree().network_peer.get_connection_status() == NetworkedMultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
		
	return true
	
################################################################

