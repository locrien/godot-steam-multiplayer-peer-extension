extends Node

var score = 0
var multiplayer_scene = preload("res://scenes/multiplayer_player.tscn")

@onready var score_label = $ScoreLabel
@export var _players_spawn_node: Node2D

func _ready():
	if OS.has_feature("dedicated_server"):
		print("Starting dedicated server...")
		_remove_single_player()
		MultiplayerManager.become_host("","",true)

func add_point():
	score += 1
	score_label.text = "You collected " + str(score) + " coins."

func become_host():
	print("Become host pressed")
	_remove_single_player()
	%MultiplayerHUD.hide()
	%SteamHUD.hide()
	MultiplayerManager.become_host("RoomName", "CoOp")
	MultiplayerManager.player_added.connect(_add_player_to_game)
	MultiplayerManager.player_removed.connect(_del_player)	
	
func join_as_client():
	print("Join as player 2")
	join_lobby()

func use_steam():
	print("Using Steam!")
	%MultiplayerHUD.hide()
	%SteamHUD.show()
	SteamManager.initialize_steam()
	Steam.lobby_match_list.connect(_on_lobby_match_list)
	MultiplayerManager.active_network_type = MultiplayerManager.MULTIPLAYER_NETWORK_TYPE.STEAM

func list_steam_lobbies():
	print("List Steam lobbies")
	MultiplayerManager.list_lobbies()

func join_lobby(lobby_id = 0):
	print("Joining lobby %s" % lobby_id)
	_remove_single_player()
	%MultiplayerHUD.hide()
	%SteamHUD.hide()
	MultiplayerManager.join_as_client(lobby_id)

func _on_lobby_match_list(lobbies: Array):
	print("On lobby match list")
	
	for lobby_child in $"../SteamHUD/Panel/Lobbies/VBoxContainer".get_children():
		lobby_child.queue_free()
		
	for lobby in lobbies:
		var lobby_name: String = Steam.getLobbyData(lobby, "name")
		
		if lobby_name != "":
			var lobby_mode: String = Steam.getLobbyData(lobby, "mode")
			
			var lobby_button: Button = Button.new()
			lobby_button.set_text(lobby_name + " | " + lobby_mode)
			lobby_button.set_size(Vector2(100, 30))
			lobby_button.add_theme_font_size_override("font_size", 8)
			
			var fv = FontVariation.new()
			fv.set_base_font(load("res://assets/fonts/PixelOperator8.ttf"))
			lobby_button.add_theme_font_override("font", fv)
			lobby_button.set_name("lobby_%s" % lobby)
			lobby_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
			lobby_button.connect("pressed", Callable(self, "join_lobby").bind(lobby))
			
			$"../SteamHUD/Panel/Lobbies/VBoxContainer".add_child(lobby_button)
			
	
func _remove_single_player():
	print("Remove single player")
	var player_to_remove = get_tree().get_current_scene().get_node("Player")
	player_to_remove.queue_free()
	
func _add_player_to_game(id: int):
	print("Player %s joined the game!" % id)
	
	var player_to_add = multiplayer_scene.instantiate()
	player_to_add.player_id = id
	player_to_add.name = str(id)
	
	_players_spawn_node.add_child(player_to_add, true)
	
func _del_player(id: int):
	print("Player %s left the game!" % id)
	if not _players_spawn_node.has_node(str(id)):
		return
	_players_spawn_node.get_node(str(id)).queue_free()
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
