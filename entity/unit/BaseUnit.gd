extends BaseEntity
class_name BaseUnit

export var team :int = 0
export var speed :int = 1

export var move_direction :Vector3
var camera_basis :Basis

var _velocity :Vector3 = Vector3.ZERO
var _up_direction :Vector3 = Vector3.UP

var _sound :AudioStreamPlayer3D
onready var _gravity :float = ProjectSettings.get_setting("physics/3d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	_sound = AudioStreamPlayer3D.new()
	_sound.unit_size = Global.sound_amplified
	add_child(_sound)
	
	if not camera_basis:
		camera_basis = self.transform.basis

	input_ray_pickable = false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float):
	_velocity = Vector3.ZERO
	_velocity = camera_basis.z * move_direction.y + camera_basis.x * move_direction.x * speed
	
	if not is_on_floor():
		_velocity.y = -_gravity
	else:
		_up_direction = get_floor_normal()
	
	if _velocity != Vector3.ZERO:
		_velocity = move_and_slide(_velocity, Vector3.UP)



