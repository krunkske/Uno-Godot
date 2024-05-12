extends Node

var rng = RandomNumberGenerator.new()

var playerNames = [] #[{"id": -1, "name": "player1"}] example
var player_order = []
var player_cards = [] #[{"id": -1, "cards": vector2i(0, 2), vector2i(2, 6), ...}] example

var current_player_pos = 0
var current_player_id = -1

var direction_switched = false
var skip_next_turn_var = false
var mid_pile = []

#common numbers
var red = 0
var yellow = 1
var green = 2
var blue = 3
var skip = 10
var switch = 11
var plus2 = 12
var switch_color = 13

func _ready() -> void:
	Aload.server_node = self

#sets up the game, sends all the players their cards, the top pile card and the player order
func start_game():
	mid_pile.append(valid_mid_pile())
	for player in playerNames:
		player_order.append(player.id)
		player_cards.append({"id": player.id, "cards": []})
	for player in player_cards:
		give_cards(player.id, 7)
	
	for player in player_cards:
		Aload.client_node.start_game.rpc_id(player.id, player.cards, mid_pile[-1], player_order)
	current_player_pos = 0
	Aload.client_node.recieve_next_player_turn.rpc(current_player_pos)
	current_player_id = player_order[0]


func give_cards(id, amount):
	for cards in player_cards:
		if cards.id == id:
			for j in range(amount):
				cards.cards.append(random_card())
				Aload.client_node.recieve_cards.rpc_id(id, [cards.cards[-1]])
				Aload.client_node.sync_cards.rpc(cards.id, [Vector2i(0, 4)])

func valid_mid_pile():
	var card = random_card()
	if card.x > 9:
		return valid_mid_pile()
	else:
		return card

#change so probabillity is better/more accurate
func random_card():
	var type = 0
	var number = 0
	var chance = rng.randi_range(1, 27)
	if chance >= 1 and chance <= 10:
		type = rng.randi_range(0,3) #includes 0 and 3
		number = rng.randi_range(0, 9)
	elif chance >= 11 and chance <= 21:
		type = rng.randi_range(0,3)
		number = rng.randi_range(10, 12)
	elif chance >= 22 and chance <= 25:
		type = 0
		number = 13
	elif chance >= 26 and chance <= 27:
		type = 4
		number = 13
	else:
		print("chance number is fucked up!!!!!")
		print(chance)
	return Vector2i(number, type)  


@rpc("any_peer", "call_remote", "reliable")
func play_card(index, color):
	if current_player_id == multiplayer.get_remote_sender_id():
		for cards in player_cards:
			if cards.id == multiplayer.get_remote_sender_id():
				if card_valid(cards.cards[index]):
					mid_pile.append(cards.cards[index])
					special_att(cards.cards[index], color)
					Aload.client_node.played_card.rpc(cards.id, cards.cards[index])
					cards.cards.pop_at(index)
					current_player_pos = next_player_turn()
					check_for_win()
					if len(cards.cards) == 1:
						Aload.client_node.start_uno_timer.rpc_id(cards.id)

@rpc("any_peer", "call_remote", "reliable")
func ask_for_card():
	if current_player_id == multiplayer.get_remote_sender_id():
		var card = random_card()
		for i in player_cards:
			if i.id == multiplayer.get_remote_sender_id():
				i.cards.append(card)
		Aload.client_node.recieve_cards.rpc_id(multiplayer.get_remote_sender_id(), [card])
		
		Aload.client_node.sync_cards.rpc(multiplayer.get_remote_sender_id(), [Vector2i(0, 4)])
		current_player_pos = next_player_turn()
		check_for_win()

@rpc("any_peer", "call_remote", "reliable")
func missed_uno():
	give_cards(multiplayer.get_remote_sender_id(), 2)

func check_for_win():
	Aload.client_node.recieve_next_player_turn.rpc(current_player_pos)
	for player in player_cards:
		if player.cards == []:
			Aload.client_node.win_or_lose.rpc(player.id)

func next_player_turn():
	var skip = 1
	var next_player = current_player_pos
	if direction_switched:
		skip = -1
	if skip_next_turn_var:
		skip *= 2
		skip_next_turn_var = false
	
	next_player += skip
	if next_player >= len(player_order):
		next_player -= len(player_order)
	elif next_player <= -1:
		next_player += len(player_order)
	
	current_player_id = player_order[next_player]
	
	return next_player

func special_att(card_type, color):
	if card_type.x == skip:
		skip_next_turn()
	elif card_type.x == switch:
		change_direction()
	elif card_type.x == plus2:
		give_cards(player_order[next_player_turn()],2)
	elif card_type.x == switch_color:
		if card_type.y == 4:
			give_cards(player_order[next_player_turn()],4)
		change_color(color)

func change_color(color):
	print(color)
	match color:
		"red":
			mid_pile[-1] = Vector2i(13, 0)
			print("changed to red")
		"yellow":
			mid_pile[-1] = Vector2i(13, 1)
			print("changed to yellow")
		"green":
			mid_pile[-1] = Vector2i(13, 2)
			print("changed to green")
		"blue":
			mid_pile[-1] = Vector2i(13, 3)
			print("changed to blue")
		_:
			print("no color found!!!!!")
	print(mid_pile[-1])

func change_direction():
	if not direction_switched:
		direction_switched = true
	elif direction_switched:
		direction_switched = false

func skip_next_turn():
	if not skip_next_turn_var:
		skip_next_turn_var = true
	elif skip_next_turn_var:
		skip_next_turn_var = false

func get_index_from_card(player, card):
	var index = 0
	for i in player.cards:
		if i.card_node == card:
			return index
		index += 1


func card_valid(card_type):
	var current_card = mid_pile[-1]
	print(current_card)
	print(card_type)
	if card_type.x <= 12 and card_type.y == current_card.y:
		return true
	elif card_type.x == current_card.x:
		return true
	elif card_type.x == 13:
		return true
	return false
