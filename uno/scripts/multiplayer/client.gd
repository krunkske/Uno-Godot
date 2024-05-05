extends Node

var playerNames = [] #[{"id": -1, "name": "player1"}] example
var player_order = []
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
	for card in cards:
		my_cards.append(card)
		Aload.deck1.add_card(card)
	
	for i in range(1, len(order)):
		for j in range(7):
			Aload.decks[i].add_card(Vector2i(0, 4))



#CHECK THESE AGAIN
@rpc("authority", "call_local", "reliable")
func recieve_cards(player_id, cards):
	for i in Aload.players:
		if i.id == player_id:
			for j in cards:
				i.cards.appemd(cards)

@rpc("authority", "call_local", "reliable")
func played_card(player_id, card):
	var index = 0
	if player_id == multiplayer.get_unique_id():
		for i in my_cards:
			if i == card:
				Aload.deck1.remove_card(index)
				my_cards.pop_at(index)
				return
			index += 1
		return
	for i in player_order:
		if i == player_id:
			Aload.decks[index].remove_card(0)
			return
		index += 1

#gets response back from server to add all of the existing players to the players array
@rpc("authority", "call_local", "reliable")
func recieve_players(users, authorized):
	Aload.client_node.playerNames = users
