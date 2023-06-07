extends Spatial
class_name FixCamera

onready var camera = $Spatial/Camera

func rotate_to(rotate_to :float):
	rotation.y = deg2rad(rotate_to)

func zoom(v :float):
	camera.translation.z = clamp(v, 20, 40)
