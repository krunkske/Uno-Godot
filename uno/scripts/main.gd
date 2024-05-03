extends Node

var screen_size
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	$pile_up.position = Vector2(screen_size.x/2+75, screen_size.y/2)
	$pile_down.position = Vector2(screen_size.x/2-75, screen_size.y/2)
	
	$player1_deck.position = Vector2(screen_size.x/2, screen_size.y - 150)
	$player1_deck.rotation_degrees = 0
	$player2_deck.position = Vector2(150, screen_size.y/2)
	$player2_deck.rotation_degrees = 90
	$player3_deck.position = Vector2(screen_size.x/2, 150)
	$player3_deck.rotation_degrees = 180
	$player4_deck.position = Vector2(screen_size.x - 150, screen_size.y/2)
	$player4_deck.rotation_degrees = -90
	
	start_game()


#will start tyhe game and give each player 7 random cards
func start_game():
	give_card(Aload.player1, 7)

func give_card(player, amount):
	for i in range(amount):
		player.cards.append({"type":random_card(), "card_node": null})
		player.deck.add_card(player.cards[-1])

#change so probabillity is better/ more accurate
func random_card():
	var type = rng.randi_range(0,3) #includes 0 and 3
	var number = rng.randi_range(0, 14)
	if number == 14:
		type = 4
		number = 13
	return Vector2i(number, type)
