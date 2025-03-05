extends Sprite2D

var tweens : Array[Tween] = []

var card_value: Vector2i
var playing_anim := false
var active := true

var rng = RandomNumberGenerator.new()

@export var base_pos : Vector2
@export var isMyCard := false
@export var isTopCard := false

func _ready() -> void:
	base_pos = position
	card_value = self.get_frame_coords()
	if not isMyCard:
		self.set_frame_coords(card_types.BACK_OF_CARD)

func set_playing_anim():
	playing_anim = false


## Kills all the tweens in the tweens array
func kill_all_tweens() -> void:
	for tween in tweens:
		if tween:
			tween.kill()
	tweens = []

## Creates a set amount of tweens and adds them to the tweens array
func create_tweens(amount : int):
	for i in range(amount):
		var tween := get_tree().create_tween()
		tweens.append(tween)

## Aniamtes the card bopping up
func bop_up():
	if not active:
		return
	#playing_anim = true
	kill_all_tweens()
	create_tweens(2)
	#self.set_z_index(1)
	tweens[0].set_ease(Tween.EASE_OUT)
	tweens[1].set_ease(Tween.EASE_OUT)
	tweens[0].set_trans(Tween.TRANS_CIRC)
	tweens[1].set_trans(Tween.TRANS_CIRC)
	tweens[0].tween_property(self, "position", position + Vector2(0, -30), 0.5)
	tweens[1].tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	#tween1.tween_callback(set_playing_anim)

## Animates the card bopping down
func bop_down():
	if not active:
		return
	#playing_anim = true
	#self.set_z_index(0)
	kill_all_tweens()
	create_tweens(2)
	tweens[0].set_ease(Tween.EASE_OUT)
	tweens[1].set_ease(Tween.EASE_OUT)
	tweens[0].set_trans(Tween.TRANS_CIRC)
	tweens[1].set_trans(Tween.TRANS_CIRC)
	tweens[0].tween_property(self, "position", base_pos, 0.5)
	tweens[1].tween_property(self, "scale", Vector2(1, 1), 0.5)
	#tween1.tween_callback(set_playing_anim)

## Animates the card going to the mid pile.
## Gives it a random rotation ofset
func go_to_middle():
	if not active:
		return
	playing_anim = true
	kill_all_tweens()
	create_tweens(3)
	tweens[0].set_trans(Tween.TRANS_CIRC)
	tweens[1].set_trans(Tween.TRANS_LINEAR)
	tweens[2].set_trans(Tween.TRANS_LINEAR)
	tweens[0].tween_property(self, "global_position", Aload.pile_up.position, 0.5)
	tweens[1].tween_property(self, "scale", Vector2(1, 1), 0.5)
	tweens[2].tween_property(self, "rotation_degrees", rng.randi_range(-10, 10), 0.5)
	#self.set_z_index(len(Aload.client_node.mid_pile)) #TODO fix ordering
	active = false

## When the mouse enteres we want to bop the card up
func _on_area_2d_mouse_entered() -> void:
	if isMyCard and not playing_anim:
		Aload.current_focussed_card = self
		bop_up()

## When the mouse exites we want the card to bop down
func _on_area_2d_mouse_exited() -> void:
	if isMyCard and not playing_anim:
		bop_down()

## Rewrite this TODO This should not handle verifying, only pass through to th Client node
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if not event.is_action_pressed("LmouseButton"):
		return
	if isTopCard:
		Server.ask_for_card.rpc_id(1)
	#var can_play : bool = event.is_action_pressed("LmouseButton") and Aload.current_focussed_card == self
	print("CLIENT %s: clicked %s" %[multiplayer.get_unique_id(), card_value])
	var index := 0 #index used to decide wich card to play from the deck
	for card in Client.myCards:
		if card == Aload.current_focussed_card.get_frame_coords():#BUG
			if card == card_types.CHANGE_COLOR_CARD or card == card_types.PLUS_4_CARD:
				Aload.color_switch_menu.choose_color(index)
			else:
				print("CLIENT %s: Playing card %s" %[multiplayer.get_unique_id(), card_value])
				Client.playCard(index, -1)
			return
		index += 1
