extends Control

var index = -1

#common numbers
## RED = 0, YELLOW = 1, GREEN = 2, BLUE = 3
enum colors {RED, YELLOW, GREEN, BLUE}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()

func choose_color(dex):
	self.show()
	index = dex


func _on_blue_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, colors.BLUE)
	self.hide()


func _on_red_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, colors.RED)
	self.hide()


func _on_yellow_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, colors.YELLOW)
	self.hide()


func _on_green_pressed() -> void:
	Aload.server_node.play_card.rpc_id(1, index, colors.GREEN)
	self.hide()
