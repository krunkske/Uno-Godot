extends Sprite2D

var tween1
var tween2

@export var base_pos = Vector2(0,0)
@export var my_card = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	base_pos = position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func bop_up():
	#self.set_z_index(1)
	tween1 = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween1.set_ease(Tween.EASE_OUT)
	tween2.set_ease(Tween.EASE_OUT)
	tween1.set_trans(Tween.TRANS_CIRC)
	tween2.set_trans(Tween.TRANS_CIRC)
	tween1.tween_property(self, "position", position + Vector2(0, -30), 0.5)
	tween2.tween_property(self, "scale", Vector2(1.1, 1.1), 0.5)

func bop_down():
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

func _on_area_2d_mouse_entered() -> void:
	if my_card:
		if Aload.current_focussed_card != null:
			Aload.current_focussed_card.bop_down()
		Aload.current_focussed_card = self
		bop_up()


func _on_area_2d_mouse_exited() -> void:
	if my_card:
		bop_down()
