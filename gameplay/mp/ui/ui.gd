extends Control
class_name UiMp

signal use_smash

var enable_smash :bool
onready var joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/joystick
onready var smash = $CanvasLayer/Control/SafeArea/VBoxContainer/smash

func get_move_direction() -> Vector3:
	var output = joystick.get_output()
	return Vector3(output.x, 0, output.y).normalized()

func _on_smash_pressed():
	enable_smash = false
	emit_signal("use_smash")

func _process(delta):
	smash.visible = enable_smash
