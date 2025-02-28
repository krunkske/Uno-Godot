extends Sprite2D

var tweens : Array[Tween] = []

var card_value
var playing_anim = false
var active = true

var rng = RandomNumberGenerator.new()

@export var base_pos : Vector2i
@export var my_card := false
@export var top_card := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_pos = position
	card_value = self.get_frame_coords()
	if not my_card:
		self.set_frame_coords(card_types.BACK_OF_CARD)


func set_playing_anim() -> void:
	playing_anim = false

func kill_all_tweens() -> void:
	for tween in tweens:
		if tween:
			tween.kill()

func create_tweens(amount : int):
	for i in range(amount):
		var tween := get_tree().create_tween()
		tweens.append(tween)

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
	self.set_z_index(len(Aload.client_node.mid_pile)) #TODO fix ordering
	active = false

func _on_area_2d_mouse_entered() -> void:
	if my_card and not playing_anim:
		if Aload.current_focussed_card != null:
			Aload.current_focussed_card.bop_down()
		Aload.current_focussed_card = self
		bop_up()


func _on_area_2d_mouse_exited() -> void:
	if my_card and not playing_anim:
		bop_down()

## Rewrite this TODO
func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	var can_play : bool = event.is_action_pressed("LmouseButton") and Aload.current_focussed_card == self
	if can_play and not top_card:
		print("clicked %s" %card_value)
		var index := 0
		for card in Aload.client_node.my_cards:
			if card == Aload.current_focussed_card.get_frame_coords():
				if card == card_types.CHANGE_COLOR_CARD or card == card_types.PLUS_4_CARD:
					Aload.color_switch_menu.choose_color(index)
					return
				else:
					Aload.server_node.play_card.rpc_id(1, index)
					return
			index += 1
	else:
		Server.ask_for_card.rpc_id(1)
