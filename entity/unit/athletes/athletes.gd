extends BaseUnit
class_name Athletes

signal smash_ready(athletes)

export var color :Color = Color.white
export var power :float  = 25.0
export var accuration :float = 0.75
export var smash_cooldown :float = 10

var use_smash :bool = false
var shot_at :Vector3
var shuttlecock :BaseProjectile

onready var animation_player = $AnimationPlayer
onready var mesh_instance = $Spatial/MeshInstance
onready var mesh_material :SpatialMaterial = mesh_instance.get_surface_material(0).duplicate()
onready var smash_cooldown_timer = $smash_cooldown

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_material.albedo_color = color
	mesh_instance.set_surface_material(0, mesh_material)
	smash_cooldown_timer.wait_time = smash_cooldown
	smash_cooldown_timer.start()

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
	animation_player.play("swing_racket")
	
func _on_service_area_body_entered(body):
	if not _is_master:
		return
	
	if not body is BaseProjectile:
		return
		
	if not body == shuttlecock:
		return
		
	swing_racket()
	
	var result :float = rand_range(power - power * 0.25, power + power * 0.25)
	shuttlecock.sender_team = team
	shuttlecock.random_offset = (1.0 - accuration) * (power + power * 0.25)
	shuttlecock.speed = result
	
	if use_smash:
		shuttlecock.speed = power * 2
		use_smash = false
		smash_cooldown_timer.wait_time = smash_cooldown
		smash_cooldown_timer.start()
		
	var _target :Vector3 = shot_at + Vector3(1, 0, 0) * rand_range(-15, 15)
	shuttlecock.target = _target
	shuttlecock.target.y = 0.5
	shuttlecock.launch()
	
func _on_smash_cooldown_timeout():
	emit_signal("smash_ready", self)
















