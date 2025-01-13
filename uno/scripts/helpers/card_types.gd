class_name card_types
#common numbers
## RED = 0, YELLOW = 1, GREEN = 2, BLUE = 3
enum colors {RED, YELLOW, GREEN, BLUE, NONE = -1}
## PLUS1 = 1, SKIP = 10, SWITCH = 11, PLUS2 = 12, SWITCH_COLOR = 13
enum card_actions {PLUS1 = 1, SKIP = 10, SWITCH = 11, PLUS2 = 12, SWITCH_COLOR = 13}

#special cards
## (0, 4)
const BACK_OF_CARD := Vector2i(0, 4)
## (0, 5)
const CHANGE_COLOR_CARD := Vector2i(0, 5)
## (0, 6)
const PLUS_4_CARD := Vector2i(0, 6)
## (0, 7)
const EMPTY_CARD := Vector2i(0, 7)
