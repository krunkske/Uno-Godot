extends Node

var playerNames = [] #[{"id": -1, "name": "player1"}] example
var player_order = []
var player_decks = []
var my_cards = [] #[vector2i(0, 2), vector2i(2, 6), ...] example

var prev_icon = null
var uno_active = false
var can_press_uno = true

var current_player_pos = 0

var direction_switched = false
var mid_pile = []

func _ready() -> void:
	Aload.client_node = self

@rpc("authority", "call_local", "reliable")
func start_game(cards, pile_up_card, order):
	Aload.uno_button.set_visible(true)
	Aload.info_node.text = ""
	Aload.pile_up.get_node("next_card").set_frame_coords(pile_up_card)
	player_order = order
	current_player_pos = 0
	
	for i in range(len(player_order) - 1):
		for j in range(7):
			Aload.decks[i + 1].add_card(Vector2i(0, 4))
	
	assing_player_decks()
	for i in Aload.player_icons_list:
		i.fade_out()

@rpc("authority", "call_remote", "reliable")
func ping():
	Aload.server_node.pong.rpc_id(1)

@rpc("authority", "call_remote", "reliable")
func change_color(color, normal):
	Aload.color = color



@rpc("authority", "call_remote", "reliable")
func start_uno_timer():
	print("started uno timer")
	Aload.uno_button.get_node("Timer").start()
	Aload.uno_button.active = true
	Aload.uno_button.start_bobbing()
	uno_active = true

func pressed_uno():
	if uno_active:
		Aload.uno_button.get_node("Timer").stop()
		uno_active = false
		print("canceled uno")
	elif can_press_uno:
		Aload.server_node.missed_uno.rpc_id(1)
		print("fucking donkey. Pressing buttons for no reason")
		$Timer.start()
		can_press_uno = false

func assing_player_decks():
	for i in player_order:
		player_decks.append(null)
	var index = 0
	for i in player_order:
		if i == multiplayer.get_unique_id():
			player_decks[index] = Aload.deck1
			break
		index += 1
	
	var position = index
	var other_index = 1 #we can skip 0 bc thats your deck
	while true:
		var checked = false
		for i in player_decks:
			if i == null:
				checked = true
		if not checked:
			return
		
		position += 1
		if position > len(player_decks) - 1:
			position = 0
		
		player_decks[position] = Aload.decks[other_index]
		
		
		Aload.player_icons_list[other_index].get_node("VBoxContainer").get_node("username").text = playerNames[position].name
		
		other_index += 1

@rpc("authority", "call_remote", "reliable")
func recieve_next_player_turn(index):
	var deckName = player_decks[index].name
	if prev_icon != null:
		prev_icon.bop_out()
	match deckName:
		"player1_deck":
			Aload.main.get_node("player_icons").get_node("player_icon1").bop_in()
			prev_icon = Aload.main.get_node("player_icons").get_node("player_icon1")
		"player2_deck":
			Aload.main.get_node("player_icons").get_node("player_icon2").bop_in()
			prev_icon = Aload.main.get_node("player_icons").get_node("player_icon2")
		"player3_deck":
			Aload.main.get_node("player_icons").get_node("player_icon3").bop_in()
			prev_icon = Aload.main.get_node("player_icons").get_node("player_icon3")
		"player4_deck":
			Aload.main.get_node("player_icons").get_node("player_icon4").bop_in()
			prev_icon = Aload.main.get_node("player_icons").get_node("player_icon4")


@rpc("authority", "call_local", "reliable")
func win_or_lose(id):
	var Uname
	for username in playerNames:
			if username.id == id:
				Uname = username.name
	if id == multiplayer.get_unique_id():
		Aload.win_screen.win_or_lose(Uname, true)
	else:
		Aload.win_screen.win_or_lose(Uname, false)

@rpc("authority", "call_local", "reliable")
func sync_cards(player_id, cards):
	var index = 0
	if player_id == multiplayer.get_unique_id():
		return
	for i in player_order:
		if i == player_id:
			for card in cards:
				player_decks[index].add_card(card)
		index += 1

@rpc("authority", "call_local", "reliable")
func recieve_cards(cards):
	for card in cards:
		my_cards.append(card)
		Aload.deck1.add_card(card)

@rpc("authority", "call_local", "reliable")
func played_card(player_id, card):
	var index = 0
	if player_id == multiplayer.get_unique_id():
		var prev_card = card
		if card.x == 13:
			if card.y > 3:
				card = Vector2i(0, 6)
			else:
				card = Vector2i(0, 5)
		for i in my_cards:
			print(i)
			if i == card:
				Aload.deck1.remove_card(index, prev_card)
				my_cards.pop_at(index)
				return
			index += 1
		return
	for i in player_order:
		if i == player_id:
			player_decks[index].remove_card(0, card)
			return
		index += 1

#gets response back from server to add all of the existing players to the players array
@rpc("authority", "call_local", "reliable")
func recieve_players(users, authorized):
	Aload.client_node.playerNames = users
	Aload.player_icons_list[0].get_node("VBoxContainer").get_node("username").text = "You"
	if authorized:
		Aload.info_gui.get_node("VBoxContainer").get_node("start").set_visible(true)


func _on_timer_timeout() -> void:
	can_press_uno = true
