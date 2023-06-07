extends BaseGameplayMp
# host

onready var athletes_team__1a = $athletes_team_1a
onready var athletes_team__1b = $athletes_team_1b
onready var athletes_team__2a = $athletes_team_2a
onready var athletes_team__2b = $athletes_team_2b
onready var reset_match_delay = $reset_match_delay

func _ready():
	_camera.rotate_to(0)
	_score_panel.rotate_to(0)
	
	_init_players()
	
	reset_match_delay.start()
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
			player.shuttlecock = shuttlecock
			player.shot_at = _arena.get_side_team(_get_opposite_team(team))
			player.connect("smash_ready", self, "_player_smash_ready")
			service_from = player
			pos += 1
			
	_reset_players_spawn_position()
	
func _on_reset_match_delay_timeout():
	_reset_players_spawn_position()
	shuttlecock.set_translation(service_from.translation + Vector3(0, 2, 0))
	shuttlecock.sender_team = service_from.team
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	._on_projectile_enter_area(projectile, area)
	if projectile.sender_team != area:
		var at = get_closes(players[area], projectile.target)
		if at.is_bot:
			at.is_moving = true
			at.move_to = projectile.target
			
func _on_projectile_hit_net(projectile :BaseProjectile):
	projectile.stop()
	_on_shuttlecock_land(projectile)
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	._on_shuttlecock_land(_shuttlecock)
	_disable_bot_moving()
	reset_match_delay.start()
	
	_sound.stream = whistle
	_sound.play()
	
func _player_use_smash():
	._player_use_smash()
	controled_player.use_smash = true
	
func _player_smash_ready(_athletes :Athletes):
	if _athletes.is_bot:
		_athletes.use_smash = randf() > 0.4
		return
		
	_ui.enable_smash = true
	
func _process(delta):
	controled_player.move_direction = .get_move_direction_with_basis_camera()
	
	var cam_pos = .get_avg_position([shuttlecock.translation] + get_players_positions(players[1]))
	_camera.translation = _camera.translation.linear_interpolate(cam_pos, 1 * delta) 
	
func _disable_bot_moving():
	for team in players.keys():
		var pos = 0
		for player in players[team]:
			if player.is_bot:
				player.is_moving = false
				
func _reset_players_spawn_position():
	for team in players.keys():
		var pos = 0
		for player in players[team]:
			player.translation = get_player_spawn_position(team, pos)
			pos += 1
			










