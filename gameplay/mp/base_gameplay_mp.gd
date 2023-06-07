extends Node
class_name BaseGameplayMp

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	
	get_tree().set_quit_on_go_back(false)
	get_tree().set_auto_accept_quit(false)
	
	init_connection_watcher()
	
	setup_enviroment()
	setup_sound()
	setup_camera()
	setup_arena()
	setup_score_panel()
	setup_shuttlecocks()
	setup_particle()
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
# rules
var service_from :Athletes
var controled_player :Athletes
var players :Dictionary = {1 : [], 2 :[]}
var teams : Array = [1,2]

################################################################
# scores
var _score_panel :ScorePanel

func setup_score_panel():
	_score_panel = preload("res://assets/score_panel/score_panel.tscn").instance()
	_score_panel.connect("time_up", self, "_time_up")
	add_child(_score_panel)
	
	_score_panel.time_remaining = 60
	_score_panel.start_timer()

var team_1_score: int = 0
var team_2_score: int = 0

func add_score(team :int):
	match (team):
		1:
			team_1_score += 1
		2:
			team_2_score += 1
			
	if not is_server():
		return
		
	rpc("_update_score", team_1_score, team_2_score)
	
remotesync func _update_score(_team_1_score, _team_2_score :int):
	if not is_server():
		team_1_score = _team_1_score
		team_2_score = _team_2_score
		
	_score_panel.show_score(team_1_score, team_2_score)
	
func show_bang(type_bang :int):
	if not is_server():
		return
		
	rpc("_show_bang", type_bang)
	
remotesync func _show_bang(type_bang :int):
	_score_panel.show_bang(type_bang)
	
func _time_up():
	if not is_server():
		return
		
	rpc("_notify_round_is_finish")
	
remotesync func _notify_round_is_finish():
	# test, just restart timer
	
	_score_panel.time_remaining = 60
	_score_panel.start_timer()
	
################################################################
# shuttlecock
var shuttlecock :BaseProjectile

func setup_shuttlecocks():
	shuttlecock = preload("res://entity/projectile/shuttlecock/shuttlecock.tscn").instance()
	shuttlecock.name = "shuttlecock"
	shuttlecock.set_network_master(Network.PLAYER_HOST_ID)
	shuttlecock.connect("launch", self, "_on_shuttlecock_launch")
	shuttlecock.connect("land", self, "_on_shuttlecock_land")
	add_child(shuttlecock)
	shuttlecock.translation = Vector3(0,20,0)
	shuttlecock.visible = false
	
func _on_shuttlecock_launch(_shuttlecock :BaseProjectile):
	_hit_particle.display_hit("", Color.white, _shuttlecock.translation)
	_sound.stream = hit
	_sound.play()
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	_hit_particle.display_hit("", Color.white, _shuttlecock.translation)
	
	if not is_server():
		return
		
	var has_in :bool = _check_team_sender_score(_shuttlecock)
	if has_in:
		return
		
	var has_hit_net :bool = _arena.is_projectile_hit_net()
	if has_hit_net:
		show_bang(3)
		add_score(_get_opposite_team(_shuttlecock.sender_team))
		return
		
	show_bang(1)
	add_score(_get_opposite_team(_shuttlecock.sender_team))
	
func _check_team_sender_score(_shuttlecock :BaseProjectile) -> bool:
	for team in teams:
		if _arena.is_side_have_projectile(team):
			show_bang(2)
			service_from = get_closes(players[team], _shuttlecock.global_transform.origin)
			if _shuttlecock.sender_team == _get_opposite_team(team):
				add_score(_get_opposite_team(team))
			return true
			
	return false
	
################################################################
# particles
var _hit_particle :HitParticle

func setup_particle():
	_hit_particle = preload("res://assets/hit_particle/hit_particle.tscn").instance()
	_hit_particle.custom_particle_scene = preload("res://assets/hit_particle/custom_particle/mesh/custom_mesh_particle.tscn")
	add_child(_hit_particle)
	
################################################################
# arena
var _arena :Arena

func setup_arena():
	_arena = preload("res://map/arena.tscn").instance()
	_arena.enable_projectile_scan = is_server()
	_arena.connect("on_projectile_enter_area", self, "_on_projectile_enter_area")
	_arena.connect("on_projectile_hit_net", self, "_on_projectile_hit_net")
	add_child(_arena)
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	# print("projectile %s enter on %s" % [projectile.name, area])
	pass
	
	
func _on_projectile_hit_net(projectile :BaseProjectile):
	#print("projectile %s hit net" % projectile.name)
	_hit_particle.display_hit("", Color.white, projectile.translation)
	
	
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
const whistle = preload("res://assets/sound/whistle.mp3")
const hit = preload("res://assets/sound/click.wav")

var _sound :AudioStreamPlayer

func setup_sound():
	whistle.loop = false
	
	_sound = AudioStreamPlayer.new()
	add_child(_sound)

################################################################
# ui
var _ui :UiMp

func setup_ui():
	_ui = preload("res://gameplay/mp/ui/ui.tscn").instance()
	_ui.connect("use_smash", self, "_player_use_smash")
	add_child(_ui)
	
func _player_use_smash():
	pass
	
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
# utils code
func get_player_spawn_position(team :int, index :int) -> Vector3:
	var pos = _arena.get_side_team(team)
	if index == 0:
		pos.x -= 6
	elif index == 1:
		pos.x += 6
		
	pos.y = 3
	return pos
	
func get_players_positions(players :Array) -> Array:
	var pos :Array = []
	for player in players:
		if player is BaseUnit:
			pos.append(player.global_transform.origin)
			
	return pos
	
func get_avg_position(list_pos :Array, y :float = 0) -> Vector3:
	var pos :Vector3 = Vector3.ZERO
	var pos_len = list_pos.size()
	for i in list_pos:
		pos += i
		
	pos = pos / pos_len
	pos.y = y
	return pos
	
func get_move_direction_with_basis_camera() -> Vector3:
	var move_direction = _ui.get_move_direction()
	var camera_basis = _camera.transform.basis
	return camera_basis.z * move_direction.z + camera_basis.x * move_direction.x
	
func get_closes(bodies :Array, from :Vector3) -> BaseUnit:
	if bodies.empty():
		return null
		
	var default :BaseUnit = bodies[0]
	for i in bodies:
		var dis_1 = from.distance_squared_to(default.global_transform.origin)
		var dis_2 = from.distance_squared_to(i.global_transform.origin)
		
		if dis_2 < dis_1:
			default = i
		
	return default

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

