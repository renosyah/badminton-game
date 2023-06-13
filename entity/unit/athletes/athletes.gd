extends BaseUnit
class_name Athletes

signal smash_ready(athletes)

const max_power :float = 100.0

export var color :Color = Color.white
export (float, 0, 1) var power :float  = 0.25
export (float, 0, 1) var skill :float  = 0.45
export (float, 0, 1) var accuration :float = 0.75

export var smash_cooldown :int = 5

var use_smash :bool = false
var shot_at :Vector3
var shuttlecock :BaseProjectile

onready var _smash_buildup :int = smash_cooldown
onready var _animation_player = $AnimationPlayer
onready var _mesh_instance = $Spatial/MeshInstance
onready var _mesh_material :SpatialMaterial = _mesh_instance.get_surface_material(0).duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	_mesh_material.albedo_color = color
	_mesh_instance.set_surface_material(0, _mesh_material)

func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_instance_valid(shuttlecock):
		var _dir = translation.direction_to(shuttlecock.global_transform.origin)
		_turn_spatial_pivot_to_moving(_dir * 100, self, delta)
	
func swing_racket():
	if not _is_master:
		return
		
	rpc("_swing_racket")
	
remotesync func _swing_racket():
	_animation_player.play("swing_racket")
	
func _on_service_area_body_entered(body):
	if not _is_master:
		return
	
	if not body is BaseProjectile:
		return
		
	if not body == shuttlecock:
		return
		
	swing_racket()
	
	var _speed :float = max_power * power
	
	shuttlecock.sender_team = team
	shuttlecock.random_offset = (1.0 - accuration) * _speed
	shuttlecock.speed = _speed
	
	if use_smash:
		shuttlecock.speed *= 2
		use_smash = false
		_smash_buildup = smash_cooldown
		
	var _skill :float = 5.0 + (10.0 * skill)
	var _target :Vector3 = shot_at + Vector3(1, 0, 0) * rand_range(-_skill, _skill)
	shuttlecock.target = _target
	shuttlecock.target.y = 0.5
	shuttlecock.launch()
	
	if _smash_buildup == 0:
		emit_signal("smash_ready", self)
		return
		
	_smash_buildup -= 1
















