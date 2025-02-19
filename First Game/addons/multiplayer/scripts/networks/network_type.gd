class_name NetworkType extends Node

signal player_added(id:int)
signal player_removed(id:int)

func become_host(lobbyName:String, lobbyMode:String):
    assert(false, "missing implementation [become_host]")

func join_as_client(lobby_id:int):
    assert(false, "missing implementation [join_as_client]")

func list_lobbies():
    assert(false, "missing implementation [list_lobbies]")
