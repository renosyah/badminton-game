extends BaseGameplayMp
# client

onready var athletes_team__1a = $athletes_team_1a
onready var athletes_team__2a = $athletes_team_2a
onready var athletes_team__1b = $athletes_team_1b
onready var athletes_team__2b = $athletes_team_2b

func _ready():
	_camera.rotate_to(180)
	_score_panel.rotate_to(180)
	
	_init_players()
	
	_sound.stream = whistle
	_sound.play()
	
func _init_players():
	controled_player = athletes_team__1a
	players = {
		1 : [athletes_team__1a, athletes_team__1b],
		2 : [athletes_team__2a, athletes_team__2b]
	}
	
	for team in players.keys():
		var pos = 0
		for player in players[team]:
			player.set_network_master(Network.PLAYER_HOST_ID)
			pos += 1
	
func _process(delta):
	controled_player.move_direction = .get_move_direction_with_basis_camera()
	
	var cam_pos = .get_avg_position([shuttlecock.translation] + get_players_positions(players[2]))
	_camera.translation = _camera.translation.linear_interpolate(cam_pos, 1 * delta) 
