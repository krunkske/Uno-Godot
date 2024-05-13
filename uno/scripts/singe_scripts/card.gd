extends Sprite2D

var tween1
var tween2
var tween3

var card_value
var playing_anim = false
var active = true

var rng = RandomNumberGenerator.new()

@export var base_pos = Vector2(0,0)
@export var my_card = false
@export var top_card = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_pos = position
	card_value = self.get_frame_coords()
	if not my_card:
		self.set_frame_coords(Vector2i(0, 4))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_playing_anim():
	playing_anim = false

func bop_up():
	if not active:
		return
	#playing_anim = true
	if tween1:
		tween1.kill()
	if tween2:
		tween2.kill()
	#self.set_z_index(1)
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween2.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_CIRC)
	tween2.set_trans(Tween.TRANS_CIRC)
	tween1.tween_property(self, "position", position + Vector2(0, -30), 0.5)
	tween2.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)
	#tween1.tween_callback(set_playing_anim)

func bop_down():
	if not active:
		return
	#playing_anim = true
	#self.set_z_index(0)
	if tween1:
		tween1.kill()
	if tween2:
		tween2.kill()
	
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween2.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_CIRC)
	tween2.set_trans(Tween.TRANS_CIRC)
	tween1.tween_property(self, "position", base_pos, 0.5)
	tween2.tween_property(self, "scale", Vector2(1, 1), 0.5)
	#tween1.tween_callback(set_playing_anim)

func go_to_middle():
	if not active:
		return
	playing_anim = true
	if tween1:
		tween1.kill()
	if tween2:
		tween2.kill()
	if tween3:
		tween3.kill()
	
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween3 = get_tree().create_tween()
	tween1.set_trans(Tween.TRANS_CIRC)
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween3.set_trans(Tween.TRANS_LINEAR)
	tween1.tween_property(self, "global_position", Aload.pile_up.position, 0.5)
	tween2.tween_property(self, "scale", Vector2(1, 1), 0.5)
	tween3.tween_property(self, "rotation_degrees", rng.randi_range(-10, 10), 0.5)
	self.set_z_index(len(Aload.client_node.mid_pile))
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


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event.is_action_pressed("LmouseButton") and Aload.current_focussed_card == self and not top_card:
		print("clicked " + str(card_value))
		var index = 0
		for i in Aload.client_node.my_cards:
			Aload.info_node.text = str(Aload.current_focussed_card.get_frame_coords())
			print(Aload.current_focussed_card.get_frame_coords())
			if i == Aload.current_focussed_card.get_frame_coords():
				if i.x == 13:
					Aload.color_switch_menu.choose_color(index)
				else:
					Aload.server_node.play_card.rpc_id(1, index, "COLOR")
				break
			index += 1
	elif event.is_action_pressed("LmouseButton") and Aload.current_focussed_card == self and top_card:
		Aload.server_node.ask_for_card.rpc_id(1)
