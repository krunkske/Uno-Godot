extends Node2D

@export var my_cards = false
var crad_scene = load("res://scenes/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if my_cards:
		for i in self.get_children():
			i.my_card = true
	else:
		for i in self.get_children():
			i.set_frame_coords(Vector2i(0, 4))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_card(type):
	var card = crad_scene.instantiate()
	card.set_frame_coords(type.type)
	type.card_node = card
	add_child(card)
	rearrange_cards()


func rearrange_cards():
	var cards
	
	match name:
		"player1_deck":
			cards = Aload.p1_cards
		"player2_deck":
			cards = Aload.p2_cards
		"player3_deck":
			cards = Aload.p3_cards
		"player4_deck":
			cards = Aload.p4_cards
	
	var card_len = len(cards)
	var tweens_move = []
	var tweens_rotate = []
	
	for i in range(card_len):
		tweens_move.append(get_tree().create_tween())
		tweens_move[-1].set_trans(Tween.TRANS_QUAD)
		tweens_rotate.append(get_tree().create_tween())
		tweens_rotate[-1].set_trans(Tween.TRANS_QUAD)
	
	var compactness = 200 - card_len*7.5
	
	for i in range(card_len):
		var j = i - card_len/2
		var j_pos = j
		if j_pos == 0:
			j_pos = 1 
		
		print("len cards: " + str(card_len))
		print("i: " + str(i))
		print("j: " + str(j))
		
		cards[i].card_node.global_position = Aload.pile_down.global_position
		cards[i].card_node.my_card = true
		cards[i].card_node.base_pos = Vector2(compactness*j,30 * absi(j_pos))
		tweens_move[i].tween_property(cards[i].card_node, "position", Vector2(compactness*j,30 * absi(j_pos)), 0.5)
		tweens_rotate[i].tween_property(cards[i].card_node, "rotation_degrees", 5*j, 0.5)
