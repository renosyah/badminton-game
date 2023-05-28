extends Spatial
class_name ScorePanel

signal time_up

export var time_remaining :int = 60
export var rotate_to :float = 0

onready var viewport = $MeshInstance/sprite3d/Viewport
onready var sprite_3d = $MeshInstance/sprite3d
onready var v_box_container = $MeshInstance/sprite3d/Viewport/VBoxContainer
onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite_3d.texture = viewport.get_texture()

func start_timer():
	v_box_container.show_time_left(time_remaining)
	timer.start()

func show_score(team_1_score, team_2_score :int):
	v_box_container.show_score(team_1_score, team_2_score)

func _on_Timer_timeout():
	time_remaining -= 1
	v_box_container.show_time_left(time_remaining)
	
	if time_remaining == 0:
		emit_signal("time_up")
		return
		
	timer.start()
	
func _process(delta):
	rotation.y = lerp_angle(rotation.y, deg2rad(rotate_to), 15 * delta)
