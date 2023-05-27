extends StaticBody
class_name Arena

signal on_projectile_enter_area(projectile, area)
signal on_projectile_exit_area(projectile, area)

func _on_side_team_1_body_entered(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_enter_area",body, 1)


func _on_side_team_2_body_entered(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_enter_area",body, 2)

func _on_side_team_1_body_exited(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_exit_area",body, 1)


func _on_side_team_2_body_exited(body):
	if not body is BaseProjectile:
		return
		
	emit_signal("on_projectile_exit_area",body, 2)

