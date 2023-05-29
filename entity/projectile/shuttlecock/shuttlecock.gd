extends BaseProjectile

onready var animation_player = $AnimationPlayer

remotesync func _launch(_target :Vector3):
	._launch(_target)
	animation_player.play("rotate")
	
remotesync func _stop():
	._stop()
	animation_player.stop()
	
remotesync func _on_land():
	._on_land()
	animation_player.stop()
