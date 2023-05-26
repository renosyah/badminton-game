extends Node

################################################################
# sound
const is_dekstop =  ["Server", "Windows", "WinRT", "X11"]
onready var sound_amplified :float = 5.0 if OS.get_name() in is_dekstop else 10.0

################################################################
# player
const player_save_file = "player.data"
onready var player :PlayerData = PlayerData.new()

################################################################

func _ready():
	var player_data = SaveLoad.load_save(player_save_file)
	if player_data == null:
		player.player_name = RandomNameGenerator.generate()
		player.player_color = Color(randf(), randf(), randf(), 1)
		player.player_team = 1
		player.save_data(player_save_file)
		
	else:
		player.load_data(player_save_file)
