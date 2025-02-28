extends Node

var screen_size: Vector2

func _ready() -> void:
	if OS.has_feature("dedicated_server") or DisplayServer.get_name() == "headless":
		Aload.headless = true
		Lobby.create_server()
	else:
		get_tree().get_root().size_changed.connect(set_pos_decks)
		set_pos_decks()

## Resets the position of all decks to be proportional to the screen size
func set_pos_decks() -> void:
	screen_size = get_viewport().get_visible_rect().size
	$pile_up.position = Vector2(screen_size.x/2+60, screen_size.y/2)
	$pile_down.position = Vector2(screen_size.x/2-60, screen_size.y/2)
	
	$player1_deck.position = Vector2(screen_size.x/2, screen_size.y - 125)
	$player1_deck.rotation_degrees = 0
	$player2_deck.position = Vector2(125, screen_size.y/2)
	$player2_deck.rotation_degrees = 90
	$player3_deck.position = Vector2(screen_size.x/2, 125)
	$player3_deck.rotation_degrees = 180
	$player4_deck.position = Vector2(screen_size.x - 125, screen_size.y/2)
	$player4_deck.rotation_degrees = -90
