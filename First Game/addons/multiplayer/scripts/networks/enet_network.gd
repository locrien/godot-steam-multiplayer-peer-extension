class_name EnetNetwork extends NetworkType

const SERVER_PORT = 8080
const SERVER_IP = "127.0.0.1"

var multiplayer_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()

func become_host(_lobbyName: String, _lobbyMode: String):
	print("Starting host!")
	
	multiplayer_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	multiplayer.peer_connected.connect(player_added.emit)
	multiplayer.peer_disconnected.connect(player_removed.emit)

	if not OS.has_feature("dedicated_server"):
		player_added.emit(1)
	
func join_as_client(_lobby_id):
	print("Player 2 joining")
	
	multiplayer_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = multiplayer_peer

func list_lobbies():
	print("No lobbies in enet mode")

	
	
	
	
	
	
	
	
