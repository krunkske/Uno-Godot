extends Node

#the ENTIRE infrastructure has to be changed from peer to peer to server
#good luck!
#I did it! Yay!
#aaand were refactoring everything lol. Good luck again!

var client_node = preload("res://scenes/client.tscn")
var server_node = preload("res://scenes/server.tscn")

var PORT = 8080
const MAX_CLIENTS = 4

var peer = null

var connected = 0

var playerName

func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)


func create_client(ip_address):
	if ip_address == "" or OS.get_name() == "Web":
		ip_address = "wss://1238900430327517204.discordsays.com/server"
	else:
		ip_address = ip_address + ":" + str(PORT)
	
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(ip_address)
	if err != OK:
		printerr(err)
		return false
	
	multiplayer.multiplayer_peer = peer
	
	var client = client_node.instantiate()
	Aload.main.add_child(client)
	
	var server = server_node.instantiate()
	Aload.main.add_child(server)
	return true

#hosting will be disabled and not included. only server-client, no peer-to-peer
func create_server():
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_server(int(PORT))
	if err != OK:
		printerr(err)
		match err:
			22:
				printerr("could not create server. Another server is already running")
			_:
				printerr("could not create server.")
		#reset func
		return
	
	print("created server at port " + str(PORT))
	multiplayer.multiplayer_peer = peer
	
	var server = server_node.instantiate()
	Aload.main.add_child(server)
	
	var client = client_node.instantiate()
	Aload.main.add_child(client)


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
	Aload.reset()
	Aload.info_node.text = "Server was full"

func _connected_ok():
	_register_player.rpc_id(1, playerName)
	print("sucessfully connected to server")
	Aload.info_node.text = "Connected to server"

func _connected_fail():
	print("connection failed.")
	Aload.reset()
	Aload.info_node.text = "connection failed"

func _player_disconnected(_id):
	if multiplayer.is_server():
		print(str(_id) + " disconnected")
		connected -= 1
		var counter = 0
		for i in Aload.server_node.playerNames:
			if i.id == _id:
				Aload.server_node.playerNames.pop_at(counter)
				print(Aload.server_node.playerNames)
				break
			counter += 1
		
		counter = 0
		for i in Aload.server_node.player_order:
			if i == _id:
				Aload.server_node.playerNames.pop_at(counter)
				break
			counter += 1
		
		counter = 0
		for i in Aload.server_node.player_cards:
			if i.id == _id:
				Aload.server_node.player_cards.pop_at(counter)
				break
			counter += 1
		if connected == 0:
			print("lobby empty, clearing")
			Aload.client_node.queue_free()
			Aload.server_node.queue_free()
			
			var server = server_node.instantiate()
			Aload.main.add_child(server)
	
			var client = client_node.instantiate()
			Aload.main.add_child(client)

func _server_disconnected():
	print("server disconnected.")
	Aload.reset()
	Aload.info_node.text = "Server disconnected"


##registers a new player and adds it to the list of players
##called only on the serevr
@rpc("any_peer", "call_remote", "reliable")
func _register_player(username):
	Aload.server_node.playerNames.append({"id": multiplayer.get_remote_sender_id(), "name": username})
	print(connected)
	if connected == 1 and Aload.headless:
		print("is master")
		Aload.authorized = multiplayer.get_remote_sender_id()
		Aload.client_node.recieve_players.rpc(Aload.server_node.playerNames, true)
	else:
		Aload.client_node.recieve_players.rpc(Aload.server_node.playerNames, false)


@rpc("any_peer", "call_remote", "reliable")
func is_authorized():
	if Aload.headless and multiplayer.get_remote_sender_id() == Aload.authorized:
		Aload.server_node.start_game()
