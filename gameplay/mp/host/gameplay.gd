extends BaseGameplayMp
# host

onready var athletes_team__1a = $athletes_team_1a
onready var athletes_team__2a = $athletes_team_2a
onready var athletes_team__1b = $athletes_team_1b
onready var athletes_team__2b = $athletes_team_2b

var service_from :Athletes
onready var reset_match_delay = $reset_match_delay

func _ready():
	_camera.rotate_to = 0
	
	athletes_team__1a.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__1b.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__2a.set_network_master(Network.PLAYER_HOST_ID)
	athletes_team__2b.set_network_master(Network.PLAYER_HOST_ID)
	
	var pos_1 = _arena.get_side_team(1)
	var pos_2 = _arena.get_side_team(2)
	
	athletes_team__1a.translation = Vector3(pos_1.x - 3, 3, pos_1.z)
	athletes_team__1b.translation = Vector3(pos_1.x + 3, 3, pos_1.z)
	athletes_team__2a.translation = Vector3(pos_2.x + 3, 3, pos_2.z)
	athletes_team__2b.translation = Vector3(pos_2.x - 3, 3, pos_2.z)
	
	athletes_team__1a.look_at(_arena.translation, Vector3.UP)
	athletes_team__1b.look_at(_arena.translation, Vector3.UP)
	athletes_team__2a.look_at(_arena.translation, Vector3.UP)
	athletes_team__2b.look_at(_arena.translation, Vector3.UP)
	
	athletes_team__1a.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	athletes_team__1b.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	athletes_team__2a.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	athletes_team__2b.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	
	# service from player
	_sound.stream = preload("res://assets/sound/whistle.mp3")
	_sound.play()
	
	service_from = athletes_team__1a
	reset_match_delay.start()
	
func _on_reset_match_delay_timeout():
	var pos_1 = _arena.get_side_team(1)
	var pos_2 = _arena.get_side_team(2)
	
	athletes_team__1a.translation = Vector3(pos_1.x - 3, 3, pos_1.z)
	athletes_team__1b.translation = Vector3(pos_1.x + 3, 3, pos_1.z)
	athletes_team__2a.translation = Vector3(pos_2.x + 3, 3, pos_2.z)
	athletes_team__2b.translation = Vector3(pos_2.x - 3, 3, pos_2.z)
	
	athletes_team__1a.look_at(_arena.translation, Vector3.UP)
	athletes_team__1b.look_at(_arena.translation, Vector3.UP)
	athletes_team__2a.look_at(_arena.translation, Vector3.UP)
	athletes_team__2b.look_at(_arena.translation, Vector3.UP)
	
	shuttlecock.translation = service_from.translation
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	._on_projectile_enter_area(projectile, area)
	
	if area == 1 and projectile.sender_team != 1:
		var a = [athletes_team__1a, athletes_team__1b]
		var at = a[rand_range(0, 2)]
		at.move_to_completed = false
		at.move_to = projectile.target
		
		
	if area == 2 and projectile.sender_team != 2:
		var b = [athletes_team__2a, athletes_team__2b]
		var at = b[rand_range(0, 2)]
		at.move_to_completed = false
		at.move_to = projectile.target
		
		
func _on_projectile_hit_net(projectile :BaseProjectile):
	projectile.stop()
	_on_shuttlecock_land(projectile)
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	._on_shuttlecock_land(_shuttlecock)
	
	_sound.stream = preload("res://assets/sound/whistle.mp3")
	_sound.play()
	
	athletes_team__1a.move_to_completed = true
	athletes_team__2a.move_to_completed = true
	athletes_team__1b.move_to_completed = true
	athletes_team__2b.move_to_completed = true
	
	var is_in :bool = false
	
	if _arena.is_side_have_projectile(1):
		is_in = true
		var a = [athletes_team__1a, athletes_team__1b]
		var at = a[rand_range(0, 2)]
		service_from = at
		if _shuttlecock.sender_team == 2:
			_ui.add_score(2)
		
	if _arena.is_side_have_projectile(2):
		is_in = true
		var b = [athletes_team__2a, athletes_team__2b]
		var at = b[rand_range(0, 2)]
		service_from = at
		if _shuttlecock.sender_team == 1:
			_ui.add_score(1)
		
		
	if not is_in:
		_ui.add_score(_get_opposite_team(_shuttlecock.sender_team))
		
	reset_match_delay.start()
	
func _on_projectile_in_athletes_range(athletes :Athletes, _shuttlecock :BaseProjectile):
	_shuttlecock.stop()
	
	athletes.look_at(_arena.translation, Vector3.UP)
	athletes.move_direction = Vector3.ZERO
	athletes.move_to_completed = true
	
	athletes.swing_racket()
	yield(athletes, "racket_swung")
	
	_sound.stream = preload("res://assets/sound/click.wav")
	_sound.play()
	
	_shuttlecock.sender_team = athletes.team
	_shuttlecock.random_offset = rand_range(5, 25)
	_shuttlecock.speed = rand_range(22, 32)
	_shuttlecock.target = _arena.get_side_team(_get_opposite_team(_shuttlecock.sender_team))
	_shuttlecock.target.y = 0.5
	_shuttlecock.launch()
	
#func _process(delta):
#	var move_direction = _ui.get_move_direction()
#	var camera_basis = _camera_team_2.transform.basis
#	athletes_team__2.move_direction = camera_basis.z * move_direction.z + camera_basis.x * move_direction.x
#





