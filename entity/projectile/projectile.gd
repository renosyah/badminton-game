extends KinematicBody
class_name BaseProjectile

signal land(projectile)

export var speed :int = 12
export var target :Vector3
export var margin :int = 1
export var curve :bool = true
export var accuration :float = 1.0
export var is_static :bool = false

var _trajectory_aim :Vector3

# misc network
var _network_timmer :Timer
var _is_online :bool = false
var _is_master :bool = false

############################################################
# multiplayer func
puppet var _puppet_rotation :Vector3
puppet var _puppet_translation :Vector3

func _network_timmer_timeout() -> void:
	_is_online = _is_network_running()
	
# Called when the node enters the scene tree for the first time.
func _ready():
	_setup_network_timer()
	set_as_toplevel(true)
	
	if _is_master:
		set_process(false)
	
func launch():
	if not _is_master:
		return
		
	var offset = (1 - accuration)
	var rand_offset = rand_range(-offset, offset) + 0.5
	target = target + (Vector3(1, 0, 1) * rand_offset)
	
	_trajectory_aim = target
	if curve:
		_trajectory_aim.y = target.y + translation.distance_to(target)
	
	look_at(_trajectory_aim, Vector3.UP)
	set_process(true)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta :float) -> void:
	moving(delta)
	
	if not _is_online:
		return
	
	if _is_master:
		master_moving(delta)
	else:
		puppet_moving(delta)
	
func moving(_delta :float) -> void:
	pass
	
func master_moving(delta :float) -> void:
	var distance :float = translation.distance_to(_trajectory_aim)
	if distance <= margin:
		set_process(false)
		rpc("_on_land")
		return
		
	var arrow_direction :Vector3 = translation.direction_to(_trajectory_aim)
	translation += arrow_direction * speed * delta
	
	if not is_static:
		look_at(_trajectory_aim, Vector3.UP)
	
	if curve and _trajectory_aim.y > target.y:
		_trajectory_aim += Vector3.DOWN * speed * delta
	
func puppet_moving(delta :float) -> void:
	translation = translation.linear_interpolate(_puppet_translation, 2.5 * delta)
	rotation.x = lerp_angle(rotation.x, _puppet_rotation.x, 5 * delta)
	rotation.y = lerp_angle(rotation.y, _puppet_rotation.y, 5 * delta)
	rotation.z = lerp_angle(rotation.z, _puppet_rotation.z, 5 * delta)
	
remotesync func _on_land():
	emit_signal("land", self)
	
############################################################
# multiplayer func
func _is_network_running() -> bool:
	var _peer :NetworkedMultiplayerPeer = get_tree().network_peer
	if not is_instance_valid(_peer):
		return false
		
	if _peer.get_connection_status() != NetworkedMultiplayerPeer.CONNECTION_CONNECTED:
		return false
		
	return true
	
func _is_master() -> bool:
	if not get_tree().network_peer:
		return false
		
	if not is_network_master():
		return false
		
	return true
	
func _setup_network_timer() -> void:
	_is_online = _is_network_running()
	_is_master = _is_master()
	
	if not _is_master:
		return
		
	if is_instance_valid(_network_timmer):
		_network_timmer.stop()
		_network_timmer.queue_free()
		
	_network_timmer = Timer.new()
	_network_timmer.wait_time = Network.LATENCY_DELAY
	_network_timmer.connect("timeout", self , "_network_timmer_timeout")
	_network_timmer.autostart = true
	add_child(_network_timmer)
	
