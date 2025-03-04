@icon("res://addons/plenticons/icons/16x/objects/coins-blue.png")
extends Node

var rng := RandomNumberGenerator.new()

#[int, String, int, Array[Vector2i]]
#hope they inplement nested types
var player_data : Array[Dictionary]= []
const example_player := {"id": -1, "username": "fred", "cards": [Vector2i()]}
var deck := []
var active_player : int
var mid_card : Vector2i

var reversed := false


#UTIL FUNCS

## Fill up the deck with all cards of an Uno deck
func fill_deck() -> void:
	print("SERVER: filling deck with new cards")
	deck = []
	for color in range(0, 4): #4 is not included
		for card in range(0, 13): #13 not included
			deck.append(Vector2i(card, color))
	for special_card in range(0, 4): #4 not included
		deck.append(Vector2i(card_types.card_actions.PLUS1, special_card))
		deck.append(card_types.PLUS_4_CARD)
		deck.append(card_types.CHANGE_COLOR_CARD)
	print("SERVER: filled deck with new cards")


## Returns a random card from the deck and removes it from the deck.
func random_card() -> Vector2i:
	#print("SERVER: picking out a random card")
	if deck != []:
		var len_deck := len(deck) - 1
		var random_pos = rng.randi_range(0, len_deck)
		var card : Vector2i = deck[random_pos]
		deck.pop_at(random_pos)
		#print("SERVER: Chose " + str(card))
		return card
	
	printerr("Ran out of cards!")
	printerr("FILLING UP THE DECK WITH NEW CARDS, RETURNING EMPTY CARD") #TODO BUG make better solution
	fill_deck()
	
	return card_types.EMPTY_CARD


## Returns the position in the player_data array that corresponds to the given id
func get_player_pos_from_id(id:int) -> int:
	var i := 0
	for player in player_data:
		if player.id == id:
			return i
		i += 1
	
	printerr("No corresponding player to id %s" %id) 
	return NAN #NAN Will cause an error

#LOCAL FUNCS

## Starts the game. Gives each player 7 cards.
func startGame():
	print("SERVER: Starting game")
	fill_deck()
	mid_card = random_card()
	active_player = player_data[0].id
	print("SERVER: Active player is " + str(active_player))
	
	#Make a playerNames and playerOrder array to send to the clients
	var playerNames :Array[String] = []
	var playerOrder :Array[int] = []
	for i in player_data:
		playerNames.append(i.username)
		playerOrder.append(i.id)
	
	
	for player in player_data:
		giveCards(player.id, 7)
		Client.startGame.rpc_id(player.id, player.cards, playerOrder, mid_card)
	Client.syncPlayers.rpc(playerNames)

## Check if a given card is a valid card to play with the current card in the middle
## CAN BE CALLED FROM ANY NODE TODO Make that not needed
func is_valid_card(card: Vector2i) -> bool:
	print("SERVER: Checking if card is valid: " + str(card))
	if card == card_types.EMPTY_CARD:
		printerr("Card is an empty card!! Returning True!!")
		return true
	if card == card_types.CHANGE_COLOR_CARD:
		return true
	elif card == card_types.PLUS_4_CARD:
		return true
	
	if card.y > 3:
		card.y -= 4
	if mid_card.y > 3:
		mid_card.y -=4
	
	if card.y == mid_card.y:
		return true
	if card.x == mid_card.x:
		return true
	
	if card.x == 13: #TODO Dunno if this check is actually needed
		return true
	
	print("SERVER: Card %s is not valid" %card)
	return false


## Returns how many players you should skip for a given card.
## Following MY rules, skip when any special card gets trown except switch dir and +4
func checkSkipAmount(card: Vector2i) -> int:
	if card.x == card_types.card_actions.SWITCH or card == card_types.PLUS_4_CARD:
		return 0
	if card.x <= 10:
		return 1
	return 0


## Checks what attributes should trigger with a specific card and does them
## Checks whether cards should be given, direction reversed and returns how many players turn should be skipped
func applySpecialAttributes(card: Vector2i) -> int:
	print("SERVER: Applying special attributes")
	if card.x == card_types.card_actions.SWITCH:
		print("SERVER: Switching direction")
		reversed != reversed
	elif card.x == card_types.card_actions.PLUS2:
		var nextPlayer := getNextPlayerPosInList()
		giveCards(player_data[nextPlayer].id, 2)
	elif card == card_types.PLUS_4_CARD:
		var nextPlayer := getNextPlayerPosInList()
		giveCards(player_data[nextPlayer].id, 4)
	elif card.x == card_types.card_actions.PLUS1 and card.y > 3:
		print("SERVER: Giving all players a card")
		for player in player_data:
			if player.id != active_player:
				giveCards(player.id, 1)
	return checkSkipAmount(card)


## Returns the index of the next player in the list, wrapping around itself if neccesary
func getNextPlayerPosInList() -> int:
	var skipAmount := 0
	var current_player_order := get_player_pos_from_id(active_player)
	if reversed:
		skipAmount *= -1
	
	var new_active_player_pos :int = current_player_order + skipAmount
	if new_active_player_pos >= len(player_data):
		new_active_player_pos -= len(player_data)
	elif active_player <= -1:
		new_active_player_pos += len(player_data)
	return new_active_player_pos


## Calculates the next player who can do an action and sets active_player to that player id
## skip_amount can be used to set how many players it should skip.
func set_next_player_turn(skip_amount) -> void:
	skip_amount += 1
	var pos : int
	for i in skip_amount:
		pos = getNextPlayerPosInList()
	active_player = player_data[pos].id
	print("SERVER: %s is the active player" %active_player)


func giveCards(playerId: int, amount: int) -> void:
	print("SERVER: Giving %s %s cards" %[playerId, amount])
	var playerPos := get_player_pos_from_id(playerId)
	for card in range(amount):
		player_data[playerPos].cards.append(random_card())

#RPC FUNCS

## Called by: Player
## Get's called by any player who can play a card. If valid it will set the mid_card to that card
@rpc("any_peer", "call_remote", "reliable")
func play_card(card_pos_in_deck:int, color:int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	print("SERVER: Recieved playing card from " + str(sender_id))
	if sender_id != active_player: return
	var pos := get_player_pos_from_id(sender_id)
	var player := player_data[pos]
	var card : Vector2i = player.cards[card_pos_in_deck]
	print("SERVER: Player played " + str(card))
	if is_valid_card(card):
		print("SERVER: Card %s is valid" %card)
		mid_card = card
		var skipAmount := applySpecialAttributes(card)
		print("SERVER: Skipping %s player(s) turn" %skipAmount)
		set_next_player_turn(skipAmount)
		Client.playedCard.rpc(card, card_pos_in_deck, active_player)
