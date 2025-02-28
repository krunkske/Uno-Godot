@icon("res://addons/plenticons/icons/16x/objects/lightning-blue.png")
extends Node

var myCards := []
var active_player : int
var mid_card : Vector2i

## Call this when the player wants to play a card
## TODO does not take special cards into account
func playCard(cardPos: int) -> bool:
	Server.mid_card = mid_card #BE WARNED, don't know the exact concequences
	if !Server.is_valid_card(myCards[cardPos]):
		return false
	Server.play_card.rpc_id(1, cardPos)
	return true

func checkSpecialAtt(card: Vector2) -> Array[int]:
	if card.x == card_types.card_actions.SKIP:
		return [1, 0] # skip turn = 1
	if card.x == card_types.card_actions.SWITCH:
		return [2, 0] # switch dir = 2
	if card.x == card_types.card_actions.PLUS2:
		return [3, 0] # plus2 = 3
	return [0, 0] # Do nothing special
