extends Node2D

@export var my_cards = false
var crad_scene = load("res://scenes/card.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if my_cards:
		for i in get_cards():
			i.my_card = true
	else:
		for i in get_cards():
			i.set_frame_coords(Vector2i(0, 4))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_cards():
	var children = self.get_children()
	var return_children = []
	for child in children:
		if not child.is_in_group("non_cards"):
			return_children.append(child)
	return return_children

func add_card(type):
	var card = crad_scene.instantiate()
	card.set_frame_coords(type)
	if name == "player1_deck":
		card.my_card = true
	add_child(card)
	card.global_position = Aload.pile_down.global_position
	rearrange_cards()

func remove_card(index, type):
	var cards = get_cards()
	var Index = 0
	for card in cards:
		if not card.is_in_group("non_cards"):
			if index == Index:
				card.go_to_middle()
				card.set_frame_coords(type)
				card.reparent(Aload.pile_up)
				rearrange_cards()
				return
			Index += 1


func rearrange_cards():
	var cards = get_cards()
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
		
		cards[i].base_pos = Vector2(compactness*j,30 * absi(j_pos))
		cards[i].playing_anim = true
		
		tweens_move[i].tween_property(cards[i], "position", Vector2(compactness*j,30 * absi(j_pos)), 0.5)
		tweens_move[i].tween_callback(cards[i].set_playing_anim)
		tweens_rotate[i].tween_property(cards[i], "rotation_degrees", 5*j, 0.5)
