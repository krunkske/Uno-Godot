extends Node

#the ENTIRE infrastructure has to be changed from peer to peer to server
#good luck!
#I did it! Yay!
#aaand were refactoring everything lol. Good luck again!

var PORT := 8080
const MAX_CLIENTS := 4

var peer : WebSocketMultiplayerPeer = null

var amount_connected := 0

var playerName

func _ready():
	multiplayer.peer_connected.connect(self._player_connected)
	multiplayer.peer_disconnected.connect(self._player_disconnected)
	multiplayer.connected_to_server.connect(self._connected_ok)
	multiplayer.connection_failed.connect(self._connected_fail)
	multiplayer.server_disconnected.connect(self._server_disconnected)

func create_client(ip_address := "127.0.0.1") -> bool:
	"""if ip_address == "" or OS.get_name() == "Web":
		ip_address = "wss://1238900430327517204.discordsays.com/server"
	else:"""
	
	ip_address = ip_address + ":" + str(PORT)
	
	peer = WebSocketMultiplayerPeer.new()
	var err = peer.create_client(ip_address)
	if err != OK:
		printerr("An error occured when creating the client: %s" %err)
		return false
	
	multiplayer.multiplayer_peer = peer
	return true

#hosting will be disabled and not included. only server-client, no peer-to-peer
func create_server() -> bool:
	peer = WebSocketMultiplayerPeer.new()
	var err := peer.create_server(int(PORT))
	if err != OK:
		match err:
			22:
				printerr("Could not create server. Another server is already running (%s)" %err)
			_:
				printerr("An error occured when creating the server: %s" %err)
		return false
	
	print("Created server at port %s" %PORT)
	multiplayer.multiplayer_peer = peer
	return true

##All
func _player_connected(_id: int) -> void:
	if multiplayer.is_server():
		if amount_connected >= 4:
			server_full.rpc_id(_id)
			return
		amount_connected += 1
		print(str(_id) + " amount_connected")

##Client
func _connected_ok() -> void:
	_register_player.rpc_id(1, playerName)
	print("Sucessfully amount_connected to server.")
	Aload.info_node.text = "amount_connected to server."

##Client
func _connected_fail() -> void:
	printerr("Connection failed.")
	Aload.reset()
	Aload.info_node.text = "Connection failed."

##All
##THIS NEEDS MAJOR REWORKS!! TODO BUG
func _player_disconnected(_id) -> void:
	if not multiplayer.is_server():
		return
	print("%s disconnected." %_id)
	amount_connected -= 1
	var counter := 0
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

func _server_disconnected() -> void:
	print("Server closed.")
	Aload.reset()
	Aload.info_node.text = "Server closed."

##registers a new player and adds it to the list of players
##Server
##NEEDS MIMOR REWORKS TODO
@rpc("any_peer", "call_remote", "reliable")
func _register_player(username: String) -> void:
	var id := multiplayer.get_remote_sender_id()
	Aload.server_node.playerNames.append({"id": id, "name": username})
	print("%s players connected." %amount_connected)
	if amount_connected == 1 and Aload.headless:
		print("%s is master" %id)
		Aload.authorized = id
		Aload.client_node.recieve_players.rpc(Aload.server_node.playerNames, true)
	else:
		Aload.client_node.recieve_players.rpc(Aload.server_node.playerNames, false)

##Client
@rpc("authority", "call_remote", "reliable")
func server_full() -> void:
	print("Server full.")
	Aload.reset()
	Aload.info_node.text = "Server was full"

##Server
##NEEDS RENAMING TODO
@rpc("any_peer", "call_remote", "reliable")
func is_authorized() -> void:
	if Aload.headless and multiplayer.get_remote_sender_id() == Aload.authorized:
		Aload.server_node.start_game()
