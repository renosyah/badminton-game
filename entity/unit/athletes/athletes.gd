extends BaseUnit
class_name Athletes

signal racket_swung
signal on_projectile_in_range(athletes, projectile)

export var color :Color = Color.white
export var use_smash :bool = false

var shuttlecock :BaseProjectile

onready var animation_player = $AnimationPlayer
onready var mesh_instance = $Spatial/MeshInstance
onready var mesh_material :SpatialMaterial = mesh_instance.get_surface_material(0).duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	mesh_material.albedo_color = color
	mesh_instance.set_surface_material(0, mesh_material)

func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_moving:
		_turn_spatial_pivot_to_moving(shuttlecock.global_transform.origin, self, delta)
	
func swing_racket():
	if not _is_master:
		return
		
	rpc("_swing_racket")
	
remotesync func _swing_racket():
	animation_player.play("swing_racket")
	
func _racket_swung():
	emit_signal("racket_swung")

func _on_service_area_body_entered(body):
	if not _is_master:
		return
	
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_in_range", self, body)
	













