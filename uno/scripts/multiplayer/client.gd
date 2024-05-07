extends Node

var playerNames = [] #[{"id": -1, "name": "player1"}] example
var player_order = []
var player_decks = []
var my_cards = [] #[vector2i(0, 2), vector2i(2, 6), ...] example

var current_player_pos = 0

var direction_switched = false
var mid_pile = []

func _ready() -> void:
	Aload.client_node = self


@rpc("authority", "call_local", "reliable")
func start_game(cards, pile_up_card, order):
	Aload.pile_up.get_node("next_card").set_frame_coords(pile_up_card)
	player_order = order
	current_player_pos = 0
	for card in cards:
		my_cards.append(card)
		Aload.deck1.add_card(card)
	
	assing_player_decks()

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

		other_index += 1

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
func recieve_cards(player_id, cards):
	for card in cards:
		my_cards.append(card)
		Aload.deck1.add_card(card)

@rpc("authority", "call_local", "reliable")
func played_card(player_id, card):
	var index = 0
	if player_id == multiplayer.get_unique_id():
		for i in my_cards:
			if i == card:
				Aload.deck1.remove_card(index, card)
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
