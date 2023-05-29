extends Spatial
class_name FixCamera

func rotate_to(rotate_to :float):
	rotation.y = deg2rad(rotate_to)
