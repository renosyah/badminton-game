extends Node

################################################################
# sound
const is_dekstop =  ["Server", "Windows", "WinRT", "X11"]
onready var sound_amplified :float = 5.0 if OS.get_name() in is_dekstop else 10.0

################################################################
# player
const player_save_file = "player.data"
onready var player :PlayerData = PlayerData.new()
onready var has_login :bool = false

################################################################

func _ready():
	var player_data = SaveLoad.load_save(player_save_file)
	if player_data == null:
		return
		
	has_login = true
	player.load_data(player_save_file)
