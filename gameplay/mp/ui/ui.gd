extends Control
class_name UiMp

signal use_smash

onready var joystick = $CanvasLayer/Control/SafeArea/VBoxContainer/HBoxContainer/joystick

func get_move_direction() -> Vector3:
	var output = joystick.get_output()
	return Vector3(output.x, 0, output.y).normalized()

func _on_smash_pressed():
	emit_signal("use_smash")
