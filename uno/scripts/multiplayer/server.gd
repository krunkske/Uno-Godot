extends Node

var rng = RandomNumberGenerator.new()

var playerNames = [] #[{"id": -1, "name": "player1"}] example
var player_order = []
var player_cards = [] #[{"id": -1, "cards": vector2i(0, 2), vector2i(2, 6), ...}] example

var current_player_pos = 0

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
	mid_pile.append(random_card())
	for player in playerNames:
		player_order.append(player.id)
		player_cards.append({"id": player.id, "cards": []})
	for player in player_cards:
		give_cards(player.id, 7)
		Aload.client_node.start_game.rpc_id(player.id, player.cards, mid_pile[-1], player_order)


func give_cards(id, amount):
	for cards in player_cards:
		if cards.id == id:
			for j in range(amount):
				cards.cards.append(random_card())



#change so probabillity is better/more accurate
func random_card():
	var type = rng.randi_range(0,3) #includes 0 and 3
	var number = rng.randi_range(0, 14)
	if number == 14:
		type = 4
		number = 13
	return Vector2i(number, type)


@rpc("any_peer", "call_remote", "reliable")
func play_card(index):
	for cards in player_cards:
		if cards.id == multiplayer.get_remote_sender_id():
			if card_valid(cards.cards[index]):
				special_att(cards.cards[index])
				mid_pile.append(cards.cards[index])
				Aload.current_focussed_card = null
				Aload.client_node.played_card.rpc(cards.id, cards.cards[index])
				cards.cards.pop_at(index)

func next_player_turn():
	var skip = 1
	var next_player = current_player_pos
	if direction_switched:
		skip = -1
	if skip_next_turn_var:
		skip *= 2
		skip_next_turn_var = false
	
	next_player += skip
	if current_player_pos == len(player_order):
		next_player = 0
	elif current_player_pos == -1:
		next_player = 3
	
	return next_player

func special_att(card_type):
	if card_type.x == skip:
		skip_next_turn()
	elif card_type.x == switch:
		change_direction()
	elif card_type.x == plus2:
		give_cards(player_order[next_player_turn()],2)
	elif card_type.x == switch_color:
		if card_type.y == 4:
			give_cards(Aload.players[next_player_turn()],4)
		change_color("red")

func change_color(color):
	match color:
		"red":
			mid_pile[-1] = Vector2i(0, 13)
		"yellow":
			mid_pile[-1] = Vector2i(1, 13)
		"green":
			mid_pile[-1] = Vector2i(2, 13)
		"blue":
			mid_pile[-1] = Vector2i(4, 13)

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
	if card_type.x <= 12 and card_type.y == current_card.y:
		return true
	elif card_type.x == current_card.x:
		return true
	elif card_type.x == 13:
		return true
	return false
