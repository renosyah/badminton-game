extends Node
class_name BaseGameplayMp

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	
	setup_enviroment()
	setup_sound()
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
var shuttlecock :BaseProjectile

func setup_shuttlecocks():
	shuttlecock = preload("res://entity/projectile/shuttlecock/shuttlecock.tscn").instance()
	shuttlecock.name = "shuttlecock"
	shuttlecock.set_network_master(Network.PLAYER_HOST_ID)
	shuttlecock.connect("land", self, "_on_shuttlecock_land")
	add_child(shuttlecock)
	shuttlecock.translation = Vector3(100,100,100)
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	pass
	
################################################################
# arena
var _arena :Arena

func setup_arena():
	_arena = preload("res://map/arena.tscn").instance()
	_arena.connect("on_projectile_enter_area", self, "_on_projectile_enter_area")
	_arena.connect("on_projectile_hit_net", self, "_on_projectile_hit_net")
	add_child(_arena)
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	# print("projectile %s enter on %s" % [projectile.name, area])
	pass
	
	
func _on_projectile_hit_net(projectile :BaseProjectile):
	#print("projectile %s hit net" % projectile.name)
	pass
	
	
func _get_opposite_team(team :int) -> int:
	match (team):
		1:
			return 2
		2:
			return 1
			
	return 0
	
################################################################
# team cameras

var _camera :FixCamera

func setup_camera():
	_camera = preload("res://assets/fix_camera/fix_camera.tscn").instance()
	add_child(_camera)
	
################################################################
# directional light
var _environment :Node

func setup_enviroment():
	_environment = preload("res://assets/enviroment/enviroment.tscn").instance()
	add_child(_environment)
	
################################################################
# sound
var _sound :AudioStreamPlayer

func setup_sound():
	_sound = AudioStreamPlayer.new()
	add_child(_sound)

################################################################
# ui
var _ui :UiMp

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

