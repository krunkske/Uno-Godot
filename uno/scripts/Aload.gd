extends Node

@onready var main = get_tree().root.get_node("main")
@onready var pile_down = main.get_node("pile_down")
@onready var pile_up = main.get_node("pile_up")

#the 4 player decks
@onready var deck1 = main.get_node("player1_deck")
@onready var deck2 = main.get_node("player2_deck")
@onready var deck3 = main.get_node("player3_deck")
@onready var deck4 = main.get_node("player4_deck")

#all of the card arrays
@onready var p1_cards = []
@onready var p2_cards = []
@onready var p3_cards = []
@onready var p4_cards = []

#the 4 players
@onready var player1 = {"name": "player 1", "id": -1, "cards": p1_cards, "deck": deck1}
@onready var player2 = {"name": "player 2", "id": -1, "cards": p2_cards, "deck": deck2}
@onready var player3 = {"name": "player 3", "id": -1, "cards": p3_cards, "deck": deck3}
@onready var player4 = {"name": "player 4", "id": -1, "cards": p4_cards, "deck": deck4}

#current focussed card
@onready var current_focussed_card = null
