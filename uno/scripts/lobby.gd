extends Node

#the ENTIRE infrastructure has to be changed from peer to peer to server
#good luck!
#I did it! Yay!


var PORT = 8080
const MAX_CLIENTS = 4

var peer = null
var headless = false

var connected = 0

func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)


func create_client(ip_address):
	if ip_address == "" or OS.get_name() == "Web":
		ip_address = "FILL IN LATER"
	else:
		ip_address = ip_address + ":" + str(PORT)
	peer = WebSocketMultiplayerPeer.new()
	print(ip_address)
	var err = peer.create_client(ip_address)
	if err != OK:
		print(err)
		return false
	multiplayer.multiplayer_peer = peer
	return true


func create_server(Name):
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_server(int(PORT))
	if err != OK:
		print(err)
		match err:
			22:
				print("could not create server. Another server is already running")
			_:
				print("could not create server.")
		#reset func
		return
	
	print("created server")
	
	if not headless:
		connected += 1
	multiplayer.multiplayer_peer = peer


func _player_connected(_id):
	if multiplayer.is_server():
		if connected == 4:
			server_full.rpc_id(_id)
			return
		connected += 1
		print(str(_id) + " connected")


@rpc("authority", "call_remote", "reliable")
func server_full():
	print("server full.")

func _connected_ok():
	_register_player.rpc_id(1, playerName)
	print("sucessfully connected to server")

func _connected_fail():
	print("connection failed.")

func _player_disconnected(_id):
	if multiplayer.is_server():
		print(str(_id) + " disconnected")
		connected -= 1
		var counter = 0
		for i in aLoad.players:
			if i.id == _id:
				aLoad.players.pop_at(counter)
				print(aLoad.players)
				return
			counter += 1
			

func _server_disconnected():
	print("server disconnected.")
	aLoad.reset()
	aLoad.top_container_box.get_node("Label").set_text("Server disconnected")

#registers a new player and adds it to the ist of players
#called on every client except sender
@rpc("any_peer", "call_remote", "reliable")
func _register_player(username):
	aLoad.players.append({"name": username, "id": multiplayer.get_remote_sender_id(), "board": null, "ready": false})
	if multiplayer.is_server():
		if connected == 1 and aLoad.headless:
			aLoad.authorized = multiplayer.get_remote_sender_id()
			recieve_players.rpc(aLoad.players, true)
		else:
			recieve_players.rpc(aLoad.players, false)
		if not aLoad.headless:
			aLoad.usernamesNodes[connected].text = username
	
	print(str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

#gets response back from server to add all of the existing players to the players array
@rpc("authority", "call_local", "reliable")
func recieve_players(users, authorized):
	if authorized:
		aLoad.top_container_box.get_node("start").set_visible(true)
	aLoad.players = users
	var i = 0
	for user in users:
		if user.id == multiplayer.get_unique_id():
			aLoad.yourPosition = i
			break
		i += 1
	i = 0
	for user in users:
		aLoad.usernamesNodes[i].text = user.name
		aLoad.boards[i].fade_in()
		i += 1

	print("playerList " + str(multiplayer.get_unique_id()) + " : " + str(aLoad.players))

@rpc("any_peer", "call_remote", "reliable")
func is_ready(index, boats):
	var id = multiplayer.get_remote_sender_id()
	if id == 0:
		id = 1
	aLoad.players[index].ready = true
	aLoad.player_boats[index] = {"id": id, "boats": boats}
	for i in len(aLoad.players):
		if not aLoad.players[i].ready:
			return
	aLoad.main.start_game.rpc()

@rpc("any_peer", "call_remote", "reliable")
func is_authorized():
	if aLoad.headless and multiplayer.get_remote_sender_id() == aLoad.authorized:
		aLoad.main.start_pregame.rpc()
	elif not aLoad.headless and multiplayer.is_server():
		aLoad.main.start_pregame.rpc()
