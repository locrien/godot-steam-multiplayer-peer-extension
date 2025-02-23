extends Node

var host_mode_enabled = false
var multiplayer_mode_enabled = false

enum MULTIPLAYER_NETWORK_TYPE { ENET, STEAM }

signal player_added(id:int)
signal player_removed(id:int)

var active_network_type: MULTIPLAYER_NETWORK_TYPE = MULTIPLAYER_NETWORK_TYPE.ENET
var active_network:NetworkType

func _build_multiplayer_network():
	if not active_network:
		print("Setting active_network")
		
		multiplayer_mode_enabled = true
		
		match active_network_type:
			MULTIPLAYER_NETWORK_TYPE.ENET:
				print("Setting network type to ENet")
				active_network = EnetNetwork.new()
				active_network.name = "EnetNetwork"
				add_child(active_network);
			MULTIPLAYER_NETWORK_TYPE.STEAM:
				print("Setting network type to Steam")
				active_network = SteamNetwork.new()
				active_network.name = "SteamNetwork"
				add_child(active_network);
			_:
				print("No match for network type!")

func become_host(lobbyName: String, lobbyMode: String, is_dedicated_server = false):
	_build_multiplayer_network()
	host_mode_enabled = true if is_dedicated_server == false else false
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
