extends BaseUnit
class_name Athletes

signal racket_swung
signal on_projectile_in_range(athletes, projectile)

onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func master_moving(delta :float) -> void:
	.master_moving(delta)
	
	if is_bot and move_to_completed:
		return
		
	_turn_spatial_pivot_to_moving(self, delta)
	
func swing_racket():
	if not _is_master:
		return
		
	rpc("_swing_racket")
	
remotesync func _swing_racket():
	animation_player.play("swing_racket")
	yield(animation_player,"animation_finished")
	emit_signal("racket_swung")

func _on_service_area_body_entered(body):
	if not _is_master:
		return
	
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_in_range", self, body)
