extends Node

@onready var main = get_tree().root.get_node("main")
@onready var pile_down = main.get_node("pile_down")
@onready var pile_up = main.get_node("pile_up")

@onready var gui_node = main.get_node("GUI")
@onready var info_gui = gui_node.get_node("info_gui")
@onready var info_node = info_gui.get_node("VBoxContainer").get_node("info")
@onready var color_switch_menu = gui_node.get_node("color_switch_menu")

#server and client node
@onready var server_node = null
@onready var client_node = null

#the 4 player decks
@onready var deck1 = main.get_node("player1_deck")
@onready var deck2 = main.get_node("player2_deck")
@onready var deck3 = main.get_node("player3_deck")
@onready var deck4 = main.get_node("player4_deck")

@onready  var decks = [deck1, deck2, deck3, deck4]

#current focussed card
@onready var current_focussed_card = null


#multiplayer stuff
@onready var authorized = 1
@onready var headless = false
