extends BaseGameplayMp
# host

onready var athletes_team__1 = $athletes_team_1
onready var athletes_team__2 = $athletes_team_2

var service_from :Athletes
onready var reset_match_delay = $reset_match_delay

func _ready():
	athletes_team__1.translation = _arena.get_side_team(1)
	athletes_team__2.translation = _arena.get_side_team(2)
	
	athletes_team__1.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	athletes_team__2.connect("on_projectile_in_range", self, "_on_projectile_in_athletes_range")
	
	athletes_team__1.look_at(_arena.translation, Vector3.UP)
	athletes_team__2.look_at(_arena.translation, Vector3.UP)
	
	_camera_team_1.camera.current = true
	shuttlecock.translation = Vector3(100,100,100)
	
	# service from player
	_sound.stream = preload("res://assets/sound/whistle.mp3")
	_sound.play()
	
	service_from = athletes_team__1
	reset_match_delay.start()
	
func _on_reset_match_delay_timeout():
	shuttlecock.translation = service_from.translation
	
func _on_projectile_enter_area(projectile :BaseProjectile, area :int):
	._on_projectile_enter_area(projectile, area)
	
	if area == 1 and projectile.sender_team != 1:
		athletes_team__1.move_to_completed = false
		athletes_team__1.move_to = projectile.target
		
		
	if area == 2 and projectile.sender_team != 2:
		athletes_team__2.move_to_completed = false
		athletes_team__2.move_to = projectile.target
		
		
func _on_projectile_hit_net(projectile :BaseProjectile):
	projectile.stop()
	_on_shuttlecock_land(projectile)
	
func _on_shuttlecock_land(_shuttlecock :BaseProjectile):
	_sound.stream = preload("res://assets/sound/whistle.mp3")
	_sound.play()
	
	athletes_team__1.move_to_completed = true
	athletes_team__2.move_to_completed = true
	
	var is_in :bool = false
	
	if _arena.is_side_have_projectile(1):
		service_from = athletes_team__1
		if _shuttlecock.sender_team == 2:
			_ui.add_score(2)
		is_in = true
		
	if _arena.is_side_have_projectile(2): 
		service_from = athletes_team__2
		if _shuttlecock.sender_team == 1:
			_ui.add_score(1)
		is_in = true
		
	if not is_in:
		_ui.add_score(_get_opposite_team(_shuttlecock.sender_team))
		
	reset_match_delay.start()
	
func _on_projectile_in_athletes_range(athletes :Athletes, _shuttlecock :BaseProjectile):
	athletes.look_at(_arena.translation, Vector3.UP)
	
	_shuttlecock.sender_team = athletes.team
	shuttlecock.random_offset = rand_range(15, 45)
	_shuttlecock.speed = rand_range(12, 32)
	_shuttlecock.target = _arena.get_side_team(_get_opposite_team(_shuttlecock.sender_team))
	_shuttlecock.target.y = 0.5
	_shuttlecock.launch()
	
	athletes.move_direction = Vector3.ZERO
	athletes.move_to_completed = true
	
	_sound.stream = preload("res://assets/sound/click.wav")
	_sound.play()
	
#func _process(delta):
#	var move_direction = _ui.get_move_direction()
#	var camera_basis = _camera_team_2.transform.basis
#	athletes_team__2.move_direction = camera_basis.z * move_direction.z + camera_basis.x * move_direction.x
#





