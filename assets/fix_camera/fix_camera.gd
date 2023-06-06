extends Spatial
class_name FixCamera

export var default_distance :float = 40

onready var camera = $Camera

func rotate_to(rotate_to :float):
	rotation.y = deg2rad(rotate_to)
