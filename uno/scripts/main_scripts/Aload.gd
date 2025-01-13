extends Node

@onready var main := get_tree().root.get_node("main")
@onready var pile_down := main.get_node("pile_down")
@onready var pile_up := main.get_node("pile_up")

@onready var gui_node := main.get_node("GUI")
@onready var lobby_ui := gui_node.get_node("lobby_UI")
@onready var color_switch_menu := gui_node.get_node("color_switch_menu")
@onready var win_screen := gui_node.get_node("win_screen")
@onready var uno_button := gui_node.get_node("uno_button")


@onready var player_icons := main.get_node("player_icons")
@onready var player_icon1 := player_icons.get_node("player_icon1")
@onready var player_icon2 := player_icons.get_node("player_icon2")
@onready var player_icon3 := player_icons.get_node("player_icon3")
@onready var player_icon4 := player_icons.get_node("player_icon4")

@onready var player_icons_list := [player_icon1, player_icon2, player_icon3, player_icon4]

#the 4 player decks
@onready var deck1 := main.get_node("player1_deck")
@onready var deck2 := main.get_node("player2_deck")
@onready var deck3 := main.get_node("player3_deck")
@onready var deck4 := main.get_node("player4_deck")

@onready  var decks = [deck1, deck2, deck3, deck4]

#current focussed card
@onready var current_focussed_card = null
@onready var color : int

#multiplayer stuff
@onready var authorized := 1
@onready var headless := false

func reset():
	lobby_ui.fade_in()
	color_switch_menu.hide()
	multiplayer.multiplayer_peer.close()
	authorized = 1
	current_focussed_card = null
	uno_button.get_node("Timer").stop()
	for i in decks:
		i.reset()
