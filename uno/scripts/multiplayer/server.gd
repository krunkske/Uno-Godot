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
var sender = -1

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
	
	$Timer.start()


func give_cards(id, amount):
	for cards in player_cards:
		if cards.id == id:
			for j in range(amount):
				cards.cards.append(random_card())
				Aload.client_node.recieve_cards.rpc_id(id, [cards.cards[-1]])
				Aload.client_node.sync_cards.rpc(cards.id, [Vector2i(0, 4)])

func valid_mid_pile():
	var card = random_card()
	print(card)
	if card.x <= 9 and card.y <= 3:
		return card
	else:
		return valid_mid_pile()

#change so probabillity is better/more accurate
func random_card():
	var type = 0
	var number = 0
	var chance = rng.randi_range(1, 23)
	if chance >= 1 and chance <= 15:
		type = rng.randi_range(0,3) #includes 0 and 3
		number = rng.randi_range(0, 9)
	elif chance >= 16 and chance <= 20:
		type = rng.randi_range(0,3)
		number = rng.randi_range(10, 13)
		if number == 13:
			type += 4
			number = 1
	elif chance == 21 or chance == 22:
		type = 5
		number = 0
	elif chance == 23:
		type = 6
		number = 0
	else:
		print("chance number is fucked up!!!!!")
		print(chance)
	return Vector2i(number, type)  


@rpc("any_peer", "call_remote", "reliable")
func play_card(index, color):
	sender = multiplayer.get_remote_sender_id()
	if current_player_id == multiplayer.get_remote_sender_id():
		for cards in player_cards:
			if cards.id == multiplayer.get_remote_sender_id():
				if card_valid(cards.cards[index]):
					mid_pile.append(cards.cards[index])
					var att = special_att(cards.cards[index], color)
					Aload.client_node.played_card.rpc(cards.id, att)
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
	var skip_turn = 1
	var next_player = current_player_pos
	if direction_switched:
		skip_turn = -1
	if skip_next_turn_var:
		skip_turn *= 2
		skip_next_turn_var = false
	
	next_player += skip_turn
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
	elif card_type.x == 0 and card_type.y == 5:
		Aload.client_node.change_color.rpc(color, true)
		change_color(color)
		var coords = Vector2i(13, 0)
		match color:
			"red":
				coords.y = 0
			"yellow":
				coords.y = 1
			"green":
				coords.y = 2
			"blue":
				coords.y = 3
		return coords
	elif card_type.x == 0 and card_type.y == 6:
		give_cards(player_order[next_player_turn()],4)
		Aload.client_node.change_color.rpc(color, false)
		change_color(color)
		var coords = Vector2i(13, 0)
		match color:
			"red":
				coords.y = 4
			"yellow":
				coords.y = 5
			"green":
				coords.y = 6
			"blue":
				coords.y = 7
		return coords
	elif card_type.x == 1 and card_type.y > 3:
		for i in player_order:
			if i != sender:
				give_cards(i, 1)
	
	return card_type

func change_color(color): #this shit is messed up
	print(color)
	match color:
		"red":
			mid_pile.append(Vector2i(13, 0))
			print("changed to red")
		"yellow":
			mid_pile.append(Vector2i(13, 1))
			print("changed to yellow")
		"green":
			mid_pile.append(Vector2i(13, 2))
			print("changed to green")
		"blue":
			mid_pile.append(Vector2i(13, 3))
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
	if card_type.x == 0 and card_type.y == 5:
		return true
	elif card_type.x == 0 and card_type.y == 6:
		return true
	
	if card_type.y > 3:
		card_type.y -= 4
	if current_card.y > 3:
		current_card.y -=4
	print("current_card: " + str(current_card))
	print("card_type: " + str(card_type))
	if card_type.x <= 12 and card_type.y == current_card.y:
		return true
	elif card_type.x == current_card.x:
		return true
	elif card_type.x == 13:
		return true
	return false

@rpc("any_peer", "call_remote", "reliable")
func pong():
	#print(str(multiplayer.get_remote_sender_id()) + " is still alive")
	pass

func _on_timer_timeout() -> void:
	Aload.client_node.ping.rpc()
