class_name SteamNetwork extends NetworkType

var multiplayer_peer: SteamMultiplayerPeer = SteamMultiplayerPeer.new()
var _hosted_lobby_id = 0

var _lobbyName:String = "BAD2233"
var _lobbyMode:String = "CoOP"

func  _ready():
	Steam.lobby_created.connect(_on_lobby_created.bind())

func become_host(lobbyName: String, lobbyMode: String):
	print("Starting host!")
	
	multiplayer.peer_connected.connect(player_added.emit)
	multiplayer.peer_disconnected.connect(player_removed.emit)
	
	_lobbyName = lobbyName
	_lobbyMode = lobbyMode
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.createLobby(Steam.LOBBY_TYPE_PUBLIC, SteamManager.lobby_max_members)
	
func join_as_client(lobby_id:int):
	print("Joining lobby %s" % lobby_id)
	Steam.lobby_joined.connect(_on_lobby_joined.bind())
	Steam.joinLobby(int(lobby_id))

func _on_lobby_created(isConnect: int, lobby_id):
	print("On lobby created")
	if isConnect == 1:
		_hosted_lobby_id = lobby_id
		print("Created lobby: %s" % _hosted_lobby_id)
		
		Steam.setLobbyJoinable(_hosted_lobby_id, true)
		
		Steam.setLobbyData(_hosted_lobby_id, "name", _lobbyName)
		Steam.setLobbyData(_hosted_lobby_id, "mode", _lobbyMode)
		
		_create_host()

func _create_host():
	print("Create Host")
	
	var error = multiplayer_peer.create_host(0)
	
	if error == OK:
		multiplayer.set_multiplayer_peer(multiplayer_peer)
		
		if not OS.has_feature("dedicated_server"):
			player_added.emit(1)
	else:
		print("error creating host: %s" % str(error))

func _on_lobby_joined(lobby: int, _permissions: int, _locked: bool, response: int):
	print("On lobby joined")
	
	if response == 1:
		var id = Steam.getLobbyOwner(lobby)
		if id != Steam.getSteamID():
			print("Connecting client to socket...")
			connect_socket(id)
	else:
		# Get the failure reason
		var FAIL_REASON: String
		match response:
			2:  FAIL_REASON = "This lobby no longer exists."
			3:  FAIL_REASON = "You don't have permission to join this lobby."
			4:  FAIL_REASON = "The lobby is now full."
			5:  FAIL_REASON = "Uh... something unexpected happened!"
			6:  FAIL_REASON = "You are banned from this lobby."
			7:  FAIL_REASON = "You cannot join due to having a limited account."
			8:  FAIL_REASON = "This lobby is locked or disabled."
			9:  FAIL_REASON = "This lobby is community locked."
			10: FAIL_REASON = "A user in the lobby has blocked you from joining."
			11: FAIL_REASON = "A user you have blocked is in the lobby."
		print(FAIL_REASON)
	
func connect_socket(steam_id: int):
	var error = multiplayer_peer.create_client(steam_id, 0)
	if error == OK:
		print("Connecting peer to host...")
		multiplayer.set_multiplayer_peer(multiplayer_peer)
	else:
		print("Error creating client: %s" % str(error))

func list_lobbies():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	# NOTE: If you are using the test app id, you will need to apply a filter on your game name
	# Otherwise, it may not show up in the lobby list of your clients
	Steam.addRequestLobbyListStringFilter("name", _lobbyName, Steam.LOBBY_COMPARISON_EQUAL)
	Steam.requestLobbyList()