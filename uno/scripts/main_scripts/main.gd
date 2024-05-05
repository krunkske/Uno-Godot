extends Node

var screen_size


func _ready() -> void:
	if OS.has_feature("dedicated_server"):
		Aload.headless = true
		Lobby.create_server()
	else:
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
