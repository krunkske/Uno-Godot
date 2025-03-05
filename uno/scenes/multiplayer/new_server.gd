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
# These functions return a specific value or execute one specific action.


## Returns the position in the player_data array that corresponds to the given id
func get_player_pos_from_id(id:int) -> int:
	var i := 0
	for player in player_data:
		if player.id == id:
			return i
		i += 1
	
	printerr("No corresponding player to id %s" %id) 
	return NAN #NAN Will cause an error


## Returns the index of the next player in the list from the current active player, wrapping around itself if neccesary
func getNextPlayerPosInList() -> int:
	var skipAmount := 1
	var currentPalyerPos := get_player_pos_from_id(active_player)
	if reversed:
		skipAmount *= -1
	
	var nextPlayerPos :int = currentPalyerPos + skipAmount
	if nextPlayerPos >= len(player_data):
		nextPlayerPos -= len(player_data)
	elif active_player <= -1:
		nextPlayerPos += len(player_data)
	return nextPlayerPos


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


## Check if a given card is valid to play with the current card in the middle
func is_valid_card(card: Vector2i) -> bool:
	print("SERVER: Checking if card is valid: " + str(card))
	print("SERVER: Mid card is %s" %mid_card)
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
## Return 0 if no extra players should be  skipped
func checkSkipAmount(card: Vector2i) -> int:
	if card.x == card_types.card_actions.SWITCH or card == card_types.PLUS_4_CARD:
		return 0
	if card.x <= 10:
		return 1
	return 0


#LOCAL MULTIPLAYER FUNCS
# These functions have an rpc call in them to one or more players


## Starts the game.
## Fills the deck and gives each player 7 cards
## Picks a random mid card
## Sets the first player who can do a move
## Notifes all players that the game has started with the needed properties
func startGame():
	print("-------------------------------------")
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
		Client.startGame.rpc_id(player.id, playerOrder, mid_card)
		giveCards(player.id, 7) #BUG RACE_CONDITION HERE!!!!
	Client.syncPlayers.rpc(playerNames)


## Checks what attributes should trigger with a specific card and applies them
## Checks whether cards should be given, direction reversed and returns how many players turn should be skipped
func applySpecialAttributes(card: Vector2i) -> int:
	print("SERVER: Checking for special attributes")
	if card.x == card_types.card_actions.SWITCH:
		print("SERVER: Switching direction")
		reversed != reversed
	elif card.x == card_types.card_actions.PLUS2:
		var nextPlayer := getNextPlayerPosInList()
		print("SERVER: Giving %s 2 cards" %player_data[nextPlayer].id)
		giveCards(player_data[nextPlayer].id, 2)
	elif card == card_types.PLUS_4_CARD:
		var nextPlayer := getNextPlayerPosInList()
		print("SERVER: Giving %s 4 cards" %player_data[nextPlayer].id)
		giveCards(player_data[nextPlayer].id, 4)
	elif card.x == card_types.card_actions.PLUS1 and card.y > 3:
		print("SERVER: Giving all players a card")
		for player in player_data:
			if player.id != active_player:
				giveCards(player.id, 1)
	return checkSkipAmount(card) #We should return how many extra players we should skip based on the given card.


## Calculates the next player who can do an action and sets active_player to that playerID
## extraSkipAmount can be used to set how many players it should skip extra above the base 1 player.
func set_next_player_turn(extraSkipAmount: int) -> void:
	extraSkipAmount += 1
	var pos : int
	for i in range(extraSkipAmount):
		pos = getNextPlayerPosInList()
	active_player = player_data[pos].id
	print("SERVER: Position %s" %pos)
	print("SERVER: %s is the new active player" %active_player)


## Gives a set amount of random cards from the deck to the specified player. 
## Sends an rpc call to all players notifying them of the new cards.
func giveCards(playerId: int, amount: int) -> void:
	print("SERVER: Giving %s %s cards" %[playerId, amount])
	var playerPos := get_player_pos_from_id(playerId)
	for i in range(amount):
		player_data[playerPos].cards.append(random_card())
	
	for player in player_data:
		var cards : Array[Vector2i]= []
		if player.id == playerId:
			for i in range(amount):
				cards.append(player.cards[len(player.cards) - i - 1])
		else:
			for i in range(amount):
				cards.append(card_types.BACK_OF_CARD)
		Client.appendCards.rpc_id(player.id, cards, playerId)


#RPC FUNCS
# These functions can be called by any client


## Can get called by any player
## when a player is allowed to play a card it will check if he can. Applies special attributes like giving cards or switching colors
@rpc("any_peer", "call_remote", "reliable")
func play_card(card_pos_in_deck:int, color:int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	print("SERVER: Recieved playing card from " + str(sender_id))
	if sender_id != active_player: 
		print("SERVER: Player %s is not the active player. Active player is %s" %[sender_id, active_player])
		return
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
