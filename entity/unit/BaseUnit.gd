extends BaseEntity
class_name BaseUnit

export var team :int = 0
export var speed :int = 1

export var move_direction :Vector3

export var is_bot :bool = false
export var move_to_completed :bool = true
export var move_to :Vector3

var _velocity :Vector3 = Vector3.ZERO

var _sound :AudioStreamPlayer3D
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

############################################################
# multiplayer func
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func _network_timmer_timeout() -> void:
	._network_timmer_timeout()
	
	if _is_master and _is_online:
		rset_unreliable("_puppet_translation", global_transform.origin)
		rset_unreliable("_puppet_rotation", global_transform.basis.get_euler())
		
############################################################
# Called when the node enters the scene tree for the first time.
func _ready():
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	input_ray_pickable = false
	
func master_moving(delta :float) -> void:
	_velocity = Vector3.ZERO
	
	# for bot
	if is_bot and not move_to_completed:
		move_direction = translation.direction_to(move_to).normalized()
		if translation.distance_to(move_to) < 0.2:
			move_to_completed = true
			
	if is_bot and move_to_completed:
		move_direction = Vector3.ZERO
		
	_velocity = move_direction * speed
	
	if not is_on_floor():
		_velocity.y = -_gravity
	
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(_velocity, Vector3.UP)
		
	
func puppet_moving(delta :float) -> void:
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)

func _turn_spatial_pivot_to_moving(_spatial :Spatial, delta :float):
	if move_direction == Vector3.ZERO:
		return
		 
	var to :Vector3 = move_direction * 100
	to.y = _spatial.translation.y
		
	var _transform :Transform = _spatial.transform.looking_at(to, Vector3.UP)
	_spatial.transform = _spatial.transform.interpolate_with(_transform, 5 * delta)

