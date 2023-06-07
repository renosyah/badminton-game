extends BaseGameplayMp
# client

onready var athletes_team__1a = $athletes_team_1a
onready var athletes_team__2a = $athletes_team_2a
onready var athletes_team__1b = $athletes_team_1b
onready var athletes_team__2b = $athletes_team_2b

func _ready():
	_camera.rotate_to(180)
	_score_panel.rotate_to(180)
	
	athletes_team__1a.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__1b.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__2a.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__2b.set_network_master(Network.PLAYER_HOST_ID)
	
func _process(delta):
	var cam_pos :Vector3
	
	if is_playing:
		cam_pos = ._get_avg_position([
			athletes_team__1a.translation,
			athletes_team__1b.translation,
			shuttlecock.translation]
		)
	else:
		cam_pos = ._get_avg_position([
			athletes_team__1a.translation,
			athletes_team__1b.translation]
		)
		
	_camera.translation = _camera.translation.linear_interpolate(cam_pos, 1 * delta) 
