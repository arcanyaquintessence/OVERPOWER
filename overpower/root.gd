extends Node

const PORT:int = 6767
const MAX_CLIENTS:int = 8
const ADDRESS:String = "localhost"

const PLAYER = preload("res://overpower/plr/plr.tscn")

func _ready() -> void:
	multiplayer.connected_to_server.connect(_connected_to_server)
	multiplayer.connection_failed.connect(_connection_failed)
	multiplayer.server_disconnected.connect(_server_disconnected)
	multiplayer.peer_connected.connect(_peer_connected)
	multiplayer.peer_disconnected.connect(_peer_disconnected)

func _connected_to_server() -> void:
	print("yipee")

func _connection_failed()->void:
	pass
	
func _server_disconnected()->void:
	pass

func _peer_connected(id:int) -> void:
	print(str(id)+" connected")
	if !multiplayer.is_server():
		return
	create_plr(id)
	
func _peer_disconnected(id:int) -> void:
	print(str(id)+" disconnected")

func _on_create_server_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = peer
	create_plr(1)

func _on_join_server_pressed() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer
	
func create_plr(id:int)->void:
	var plr = PLAYER.instantiate()
	plr.name = str(id)
	plr.set_multiplayer_authority(id)
	$Players.add_child(plr)

@rpc
func get_msg(msg:String)->void:
	print(msg)

@rpc("any_peer")
func pong():
	print("pong | is_server:"+str(multiplayer.is_server()))
	
@rpc
func ping():
	print("ping | is_server:"+str(multiplayer.is_server()))
	pong.rpc_id(1)

func _on_send_information_pressed() -> void:
	if multiplayer.is_server():
		ping.rpc()
