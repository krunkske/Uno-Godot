extends Control

var index = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func choose_color(dex):
	print("did shit")
	self.set_visible(true)
	index = dex
	


func _on_blue_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "blue")
	self.set_visible(false)


func _on_red_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "red")
	self.set_visible(false)


func _on_yellow_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "yellow")
	self.set_visible(false)


func _on_green_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "yellow")
	self.set_visible(false)
