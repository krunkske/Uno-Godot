extends Node

var rng := RandomNumberGenerator.new()

#[int, String, int, Array[Vector2i]]
#hope they inplement nested types
var player_data : Array[Dictionary]= []
const example_player := {"id": -1, "username": "fred", "order": 1, "cards": [Vector2i()]}
var deck := []
var active_player : int
var mid_card : Vector2i

var reversed := false

func _ready() -> void:
	pass

#UTIL FUNCS

## Fill up the deck with all cards of an Uno deck
func fill_deck() -> void:
	deck = []
	for color in range(0, 4): #4 is not included
		for card in range(0, 13): #13 not included
			deck.append(Vector2i(card, color))
	for special_card in range(0, 4): #4 not included
		deck.append(Vector2i(card_types.card_actions.PLUS1, special_card))
		deck.append(card_types.PLUS_4_CARD)
		deck.append(card_types.CHANGE_COLOR_CARD)

## Returns a random card from the deck and removes it from the deck.
func random_card() -> Vector2i:
	if deck != []:
		var len_deck := len(deck) - 1
		var random_pos = rng.randi_range(0, len_deck)
		var card : Vector2i = deck[random_pos]
		deck.pop_at(random_pos)
		return card
	
	printerr("FILLING UP THE DECK WITH NEW CARDS") #TODO BUG make better solution
	fill_deck()
	
	printerr("Ran out of cards!")
	return card_types.EMPTY_CARD

## Returns the position in the player_data array that corresponds to the given id
func get_player_pos_from_id(id:int) -> int:
	var i := 0
	for player in player_data:
		if player.id == id:
			return i
		i += 1
	
	printerr("No corresponding player to id %s" %id) 
	return INF #INF will in most circomstances for this func cause an error


#LOCAL FUNCS

## Check if a given card is a valid card to play with the current card in the middle
func is_valid_card(card: Vector2i) -> bool:
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
	
	return false

## Calculates the next player who can do an action and sets active_player to that player id
## skip_amount can be used to set how many players it should skip, defaults to 0
func set_next_player_turn(skip_amount := 0) -> void:
	skip_amount += 1
	var current_player_pos := get_player_pos_from_id(active_player)
	var current_player_order : int = player_data[current_player_pos].order
	if reversed:
		skip_amount *= -1
	
	var new_active_player_pos := current_player_order + skip_amount
	if new_active_player_pos >= len(player_data):
		new_active_player_pos -= len(player_data)
	elif active_player <= -1:
		new_active_player_pos += len(player_data)
	
	active_player = player_data[new_active_player_pos].id

#RPC FUNCS


## Called by: Player
## Get's called by any player who can play a card. If valid it will set the mid_card to that card
@rpc("any_peer", "call_remote", "reliable")
func play_card(card_pos_in_deck:int) -> void:
	var sender_id := multiplayer.get_remote_sender_id()
	if sender_id != active_player: return
	var pos := get_player_pos_from_id(sender_id)
	var player := player_data[pos]
	var card : Vector2i = player.cards[card_pos_in_deck]
	if is_valid_card(card):
		mid_card = card
