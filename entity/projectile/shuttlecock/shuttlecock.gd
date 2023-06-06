extends BaseProjectile

onready var animation_player = $AnimationPlayer
onready var trail_render = $TrailRender

func _ready():
	trail_render.render = false

remotesync func _launch(_target :Vector3):
	._launch(_target)
	trail_render.render = true
	animation_player.play("rotate")
	
remotesync func _stop():
	._stop()
	animation_player.stop()
	
remotesync func _on_land():
	._on_land()
	animation_player.stop()
	
remotesync func _set_translation(v :Vector3):
	trail_render.render = false
	yield(get_tree(),"idle_frame")
	._set_translation(v)
	
