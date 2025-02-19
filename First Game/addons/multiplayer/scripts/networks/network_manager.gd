extends Node

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

@export var _players_spawn_node: Node2D

signal player_added(id:int)
signal player_removed(id:int)

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
# @export var _enet_node: PackedScene
var enet_network_scene := preload("res://addons/multiplayer/scenes/networks/enet_network.tscn")
var steam_network_scene := preload("res://addons/multiplayer/scenes/networks/steam_network.tscn")
var active_network:NetworkType

func _build_multiplayer_network():
	if not active_network:
		print("Setting active_network")
		
		MultiplayerManager.multiplayer_mode_enabled = true
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				_set_active_network(enet_network_scene)
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				_set_active_network(steam_network_scene)
			_:
				print("No match for network type!")

func _set_active_network(active_network_scene):
	var network_scene_initialized = active_network_scene.instantiate()
	active_network = network_scene_initialized
	add_child(active_network)

func become_host(lobbyName: String, lobbyMode: String, is_dedicated_server = false):
	_build_multiplayer_network()
	MultiplayerManager.host_mode_enabled = true if is_dedicated_server == false else false
	active_network.player_added.connect(player_added.emit)
	active_network.player_removed.connect(player_removed.emit)
	await Engine.get_main_loop().process_frame
	active_network.become_host(lobbyName, lobbyMode)

func join_as_client(lobby_id = 0):
	_build_multiplayer_network()
	active_network.join_as_client(lobby_id)
	
func list_lobbies():
	_build_multiplayer_network()
	active_network.list_lobbies()
