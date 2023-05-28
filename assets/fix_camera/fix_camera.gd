extends Spatial
class_name FixCamera

export var rotate_to :float

func _process(delta):
	rotation.y = lerp_angle(rotation.y, deg2rad(rotate_to), 15 * delta)
