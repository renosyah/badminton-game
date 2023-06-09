extends StaticBody
class_name Arena

signal on_projectile_hit_net(projectile)
signal on_projectile_enter_area(projectile, area)

export var enable_projectile_scan :bool = true

onready var net_area = $net_area
onready var side_team__1 = $side_team_1
onready var side_team__2 = $side_team_2
onready var tween = $Tween
onready var net = $net

func _ready():
	net_area.set_deferred("monitoring", enable_projectile_scan)
	side_team__1.set_deferred("monitoring", enable_projectile_scan)
	side_team__2.set_deferred("monitoring", enable_projectile_scan)
	
func is_projectile_hit_net() -> bool:
	return _have_have_projectile(net_area.get_overlapping_bodies())

func is_side_have_projectile(team :int) -> bool:
	if not side_team__1.monitoring or not side_team__2.monitoring:
		return false
		
	match (team):
		1:
			return _have_have_projectile(side_team__1.get_overlapping_bodies())
		2:
			return _have_have_projectile(side_team__2.get_overlapping_bodies())
			
	return false
	
func _have_have_projectile(bodies :Array) -> bool:
	for b in bodies:
		if b is BaseProjectile:
			return true
		
	return false

func get_side_team(team :int) -> Vector3:
	match (team):
		1:
			return side_team__1.global_transform.origin
		2:
			return side_team__2.global_transform.origin
			
	return global_transform.origin

func _on_side_team_1_body_entered(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_enter_area",body, 1)
	
func _on_side_team_2_body_entered(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_enter_area",body, 2)
	
func _on_net_area_body_entered(body):
	if not body is BaseProjectile:
		return
	
	tween.interpolate_property(net, "scale", Vector3.ONE * 0.85, Vector3.ONE, 0.2,Tween.TRANS_BOUNCE)
	tween.start()
	
	emit_signal("on_projectile_hit_net", body)






