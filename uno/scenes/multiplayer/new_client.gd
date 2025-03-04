@icon("res://addons/plenticons/icons/16x/objects/lightning-blue.png")
extends Node

var myCards := []
var playerOrder :Array[int] = []
var active_player : int
var mid_card : Vector2i


@rpc("authority", "call_remote", "reliable")
func startGame(yourCards: Array, newPlayerOrder: Array[int], midCard: Vector2i) -> void:
	myCards = yourCards
	playerOrder = newPlayerOrder
	active_player = newPlayerOrder[0]
	mid_card = midCard
	Aload.pile_up.get_node("next_card").set_frame_coords(midCard)
	Aload.deck1.my_cards = true
	var index := 0
	for playerId in playerOrder:
		if playerId == multiplayer.get_unique_id():
			for card in myCards:
				Aload.decks[0].add_card(card)
		else:
			for i in range(7):
				Aload.decks[index + 1].add_card(card_types.BACK_OF_CARD)
			index += 1

## Call this when the player wants to play a card
## TODO does not take special cards into account
func playCard(cardPos: int, color: int) -> bool:
	print("Client playin card")
	var prevMid :Vector2i = Server.mid_card
	var playedCard :Vector2i = myCards[cardPos]
	Server.mid_card = mid_card #BE WARNED, don't know the exact concequences
	if !Server.is_valid_card(myCards[cardPos]):
		Server.mid_card = prevMid
		printerr("Not a valid card")
		return false
	Server.play_card.rpc_id(1, cardPos, color)
	return true


@rpc("authority", "call_remote", "reliable")
func playedCard(playedCard: Vector2i, indexOfCard: int, newActivePlayer: int) -> void:
	var i := 0
	for playerId in playerOrder:
		if playerId == active_player:
			Aload.decks[i].remove_card(indexOfCard, playedCard)
		i+=1
	active_player = newActivePlayer


@rpc("authority", "call_remote", "reliable")
func syncPlayers(playerNames: Array[String]) -> void:
	if len(playerNames) > 4:
		printerr("Length cannot be more than 3")
		breakpoint
		return
	for index in range(len(playerNames)):
		Aload.player_icons_list[index].username = playerNames[index]
		print(Aload.player_icons_list[index].username)
