extends Control

var index = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func choose_color(dex):
	self.show()
	index = dex


func _on_blue_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "blue")
	self.hide()


func _on_red_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "red")
	self.hide()


func _on_yellow_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "yellow")
	self.hide()


func _on_green_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, "green")
	self.hide()
