@icon("res://addons/plenticons/icons/16x/objects/lightning-blue.png")
extends Node

var myCards := []
var playerOrder : Array[int] = []
var active_player : int
var mid_card : Vector2i


#UTIL FUNCS
# These functions return a specific value or execute one specific action.


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


## Shifts the given array of id's so that your id is the first one in the array.
func shiftPlayerOrder(newPlayerOrder: Array) -> Array:
	var startIndex := newPlayerOrder.find(multiplayer.get_unique_id()) # Find your position in the array
	
	if startIndex == -1:
		print("Error: Player ID not found in the list!")
		return newPlayerOrder # Return the original order if ID is not found
	
	# Create a new array starting from your position and wrapping around
	var sortedPlayerOrder = newPlayerOrder.slice(startIndex) + newPlayerOrder.slice(0, startIndex)
	
	print("CLIENT %s: %s is the player order" % [multiplayer.get_unique_id(), str(sortedPlayerOrder)])
	return sortedPlayerOrder


#LOCAL MULTIPLAYER FUNCS
# These functions have an rpc call in them to one or more players


## Call this when the player wants to play a card
## TODO does not take special cards into account
func playCard(cardPos: int, color: int) -> bool:
	print("Client playin card")
	if !is_valid_card(myCards[cardPos]):
		printerr("Not a valid card")
		return false
	Server.play_card.rpc_id(1, cardPos, color)
	return true


#RPC FUNCS
# These functions are called by the server


## Gets called from the server once the game starts
## All variables are set acoordingly 
## The right player order gets decided
## Gives each player 7 cards
@rpc("authority", "call_remote", "reliable")
func startGame(newPlayerOrder: Array[int], midCard: Vector2i) -> void:
	print("CLIENT %s: Starting the game" %multiplayer.get_unique_id())
	playerOrder = shiftPlayerOrder(newPlayerOrder)
	active_player = newPlayerOrder[0]
	mid_card = midCard
	Aload.pile_up.get_node("next_card").set_frame_coords(midCard)
	Aload.deck1.my_cards = true
	"""var index := 0
	for playerId in playerOrder:
		if playerId == multiplayer.get_unique_id():
			for card in myCards:
				Aload.decks[0].add_card(card)
		else:
			for i in range(7):
				Aload.decks[index + 1].add_card(card_types.BACK_OF_CARD)
			index += 1"""


## Gets called from the server when any player (even yourself) has played a card.
## Remove that card from the deck and add it to the mid pile
@rpc("authority", "call_remote", "reliable")
func playedCard(playedCard: Vector2i, indexOfCard: int, newActivePlayer: int) -> void:
	var i := 0
	for playerId in playerOrder:
		if playerId == active_player:
			Aload.decks[i].remove_card(indexOfCard, playedCard)
		i+=1
	active_player = newActivePlayer
	mid_card = playedCard


## Gets called by the server to set each player icon for each connected player
## TODO take care of disconnectd players
@rpc("authority", "call_remote", "reliable")
func syncPlayers(playerNames: Array[String]) -> void:
	if len(playerNames) > 4:
		printerr("Length cannot be more than 3")
		breakpoint
		return
	for index in range(len(playerNames)):
		Aload.player_icons_list[index].username = playerNames[index]


@rpc("authority", "call_remote", "reliable")
func appendCards(cards: Array[Vector2i], playerId: int) -> void:
	print("CLIENT %s: appending %s cards to %s" %[multiplayer.get_unique_id(), cards, playerId])
	if playerId == multiplayer.get_unique_id():
		for card in cards:
			myCards.append(card)
			Aload.deck1.add_card(card)
		return
	var index := 0
	if playerOrder == []:
		printerr("CLIENT %s: The player oreder is empty. Cannot distribute cards. Going into an infinite loop..." %multiplayer.get_unique_id())
		while playerOrder ==[]:
			await get_tree().create_timer(0.1).timeout
	for i in playerOrder:
		if i == playerId:
			print("CLIENT %s: index: %s, playerOrder: %s" %[multiplayer.get_unique_id(), index, playerOrder])
			for card in cards:
				Aload.decks[index].add_card(card)
		index += 1
