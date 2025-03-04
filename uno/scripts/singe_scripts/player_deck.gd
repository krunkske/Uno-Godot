extends Node2D

@export var my_cards := false
var crad_scene := load("res://scenes/card.tscn")

## deletes all the cards form the deck
func reset() -> void:
	for i in get_cards():
		i.queue_free()


## Returns all the child cards of this deck
func get_cards() -> Array:
	var children := self.get_children()
	var return_children := []
	for child in children:
		if not child.is_in_group("non_cards"):
			return_children.append(child)
	return return_children

## Adds a new card to the deck and rearranges the cards
func add_card(type: Vector2i) -> void:
	var card = crad_scene.instantiate()
	card.set_frame_coords(type)
	card.isMyCard = my_cards
	add_child(card)
	card.global_position = Aload.pile_down.global_position #why??
	rearrange_cards()


## Removes a card from the deck and moves it to the middle. Reparents the card to the mid deck
func remove_card(index: int, type: Vector2i):
	var cards := get_cards()
	var Index := 0
	for card in cards:
		if not card.is_in_group("non_cards"):
			if index == Index:
				card.reparent(Aload.pile_up)
				card.go_to_middle()
				card.set_frame_coords(type)
				rearrange_cards()
				return
			Index += 1

## Re-arranges the cards and sorts them (not inplemented) based on number and color.
## I ain't fucking with this. It works so it's fine
func rearrange_cards():
	var cards := get_cards()
	var card_len := len(cards)
	var tweens_move = []
	var tweens_rotate = []
	
	for i in range(card_len):
		tweens_move.append(get_tree().create_tween())
		tweens_move[-1].set_trans(Tween.TRANS_QUAD)
		tweens_rotate.append(get_tree().create_tween())
		tweens_rotate[-1].set_trans(Tween.TRANS_QUAD)
		
	
	var compactness := 200 - card_len*7.5
	
	for i in range(card_len):
		var j := i - card_len/2
		var j_pos := j
		if j_pos == 0:
			j_pos = 1 
		
		cards[i].base_pos = Vector2(compactness*j,30 * absi(j_pos))
		cards[i].playing_anim = true
		
		tweens_move[i].tween_property(cards[i], "position", Vector2(compactness*j,30 * absi(j_pos)), 0.5)
		tweens_move[i].tween_callback(cards[i].set_playing_anim)
		tweens_rotate[i].tween_property(cards[i], "rotation_degrees", 5*j, 0.5)
