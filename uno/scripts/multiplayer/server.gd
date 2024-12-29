extends Node

var rng = RandomNumberGenerator.new()

var playerNames := [] #[{"id": -1, "name": "player1"}] example
var player_order := []
var player_cards := [] #[{"id": -1, "cards": vector2i(0, 2), vector2i(2, 6), ...}] example

var current_player_pos := 0
var current_player_id := -1

var direction_switched := false
var skip_next_turn := false
var mid_pile := []
var sender := -1


#common numbers
## RED = 0, YELLOW = 1, GREEN = 2, BLUE = 3
enum colors {RED, YELLOW, GREEN, BLUE}
## PLUS1 = 1, SKIP = 10, SWITCH = 11, PLUS2 = 12, SWITCH_COLOR = 13
enum card_actions {PLUS1 = 1, SKIP = 10, SWITCH = 11, PLUS2 = 12, SWITCH_COLOR = 13}

#special cards
## (0, 4)
const BACK_OF_CARD := Vector2i(0, 4)
## (0, 5)
const CHANGE_COLOR_CARD := Vector2i(0, 5)
## (0, 6)
const PLUS_4_CARD := Vector2i(0, 6)
## (0, 7)
const EMPTY_CARD := Vector2i(0, 7)

func _ready() -> void:
	Aload.server_node = self

func get_cards_pos_from_id(id:int) -> int:
	var pos := 0
	for cards in player_cards:
		if cards.id == id:
			return pos
		pos += 1
	return -1

func get_index_from_card(player, card):
	var index := 0
	for i in player.cards:
		if i.card_node == card:
			return index
		index += 1


#sets up the game, sends all the players their cards, the top pile card and the player order
func start_game():
	mid_pile.append(random_card(true)) #first card cannot be a special card
	for player in playerNames:
		player_order.append(player.id)
		player_cards.append({"id": player.id, "cards": []})
	for player in player_cards:
		give_cards(player.id, 7)
	
	for player in player_cards: #can't be in prev loop cuz of BUG: player gets 2x cards
		Aload.client_node.start_game.rpc_id(player.id, player.cards, mid_pile[-1], player_order)
	
	current_player_pos = 0
	Aload.client_node.recieve_next_player_turn.rpc(current_player_pos)
	current_player_id = player_order[0]
	
	$Timer.start()

## Gives a specified amount of random cards to a player.
func give_cards(id, amount) -> void:
	var cards = player_cards[get_cards_pos_from_id(id)]
	for i in range(amount):
		cards.cards.append(random_card())
		Aload.client_node.recieve_cards.rpc_id(id, [cards.cards[-1]])
		Aload.client_node.sync_cards.rpc(cards.id, [Vector2i(0, 4)])


#TODO: change so probabillity is better/more accurate
## Returns a random card. No_special_cards can be used to only return 0-9 cards from all colors
func random_card(no_special_cards := false) -> Vector2i:
	var chance_of_card = randi_range(0, 15) #all types of cards
	if no_special_cards:
		chance_of_card = randi_range(0, 9)
	var chance_of_color = randi_range(0, 3) #all colors
	
	if chance_of_card <= 12: #normal color cards
		return Vector2i(chance_of_card, chance_of_color)
	
	match chance_of_card:
		13: #change color card
			return CHANGE_COLOR_CARD
		14: #plus 4 card
			return PLUS_4_CARD
		15: #plus 1 card
			return Vector2i(card_actions.PLUS1, chance_of_color + 4) #shift by 4
	
	printerr("Random_card failed. Giving empty card. Please check!!")
	return EMPTY_CARD
	
	"""
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
	return Vector2i(number, type)"""


@rpc("any_peer", "call_remote", "reliable")
func play_card(index, color):
	sender = multiplayer.get_remote_sender_id()
	if current_player_id != multiplayer.get_remote_sender_id():
		return
	var cards = player_cards[get_cards_pos_from_id(sender)]
	if card_valid(cards.cards[index]):
		mid_pile.append(cards.cards[index])
		var att = special_att(cards.cards[index], color)
		cards.cards.pop_at(index)
		Aload.client_node.played_card.rpc(cards.id, att)
		current_player_pos = next_player_turn()
		check_for_win()
		if len(cards.cards) == 1:
			Aload.client_node.start_uno_timer.rpc_id(cards.id)


@rpc("any_peer", "call_remote", "reliable")
func ask_for_card():
	sender = multiplayer.get_remote_sender_id()
	if current_player_id != sender:
		return
	var card := random_card()
	var cards = player_cards[get_cards_pos_from_id(sender)]
	cards.cards.append(card)
	Aload.client_node.recieve_cards.rpc_id(sender, [card])
	
	Aload.client_node.sync_cards.rpc(sender, [BACK_OF_CARD])
	current_player_pos = next_player_turn()
	check_for_win()

#TODO add more checks and fix a possible race cond..
@rpc("any_peer", "call_remote", "reliable")
func missed_uno():
	give_cards(multiplayer.get_remote_sender_id(), 2)

## Call after every player move to see if any of the players won
func check_for_win():
	Aload.client_node.recieve_next_player_turn.rpc(current_player_pos)
	for player in player_cards:
		if player.cards == []:
			Aload.client_node.win_or_lose.rpc(player.id)

## Used for calculating the nexts player turn
func next_player_turn() -> int:
	var next_turn := 1
	var next_player_pos := current_player_pos
	if direction_switched:
		next_turn = -1
	if skip_next_turn:
		next_turn *= 2
		skip_next_turn = false
	
	next_player_pos += next_turn
	if next_player_pos >= len(player_order):
		next_player_pos -= len(player_order)
	elif next_player_pos <= -1:
		next_player_pos += len(player_order)
	
	current_player_id = player_order[next_player_pos] #BUG error occurs here when there's only 1 player and we play a skip card
	
	return next_player_pos

func special_att(card, color):
	if card.x == card_actions.SKIP:
		skip_next_turn != skip_next_turn
	elif card.x == card_actions.SWITCH:
		direction_switched != direction_switched
	elif card.x == card_actions.PLUS2:
		give_cards(player_order[next_player_turn()],2)
	elif card.x == 0 and card.y == 5:
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
	elif card.x == 0 and card.y == 6:
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
	elif card.x == 1 and card.y > 3:
		for i in player_order:
			if i != sender:
				give_cards(i, 1)
	
	return card

func change_color(color): #this shit is messed up
	print(color)
	match color:
		"red":
			mid_pile.append(Vector2i(13, colors.RED))
			print("changed to red")
		"yellow":
			mid_pile.append(Vector2i(13, colors.YELLOW))
			print("changed to yellow")
		"green":
			mid_pile.append(Vector2i(13, colors.GREEN))
			print("changed to green")
		"blue":
			mid_pile.append(Vector2i(13, colors.BLUE))
			print("changed to blue")
		_:
			print("no color found!!!!!")
	print(mid_pile[-1])


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
