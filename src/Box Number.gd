extends Control
onready var button = $Buy
onready var text = $Popup/Earnings
onready var popup = $Popup

var level: int = 1
var ball: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Data.connect("update_game_interface", self, "update_interface")
	update_interface()

func update_interface() -> void: # Updates the buttons data
	button.text = "Purchase 5 more boxes for %s" % Data.beautify(Data.box_number_cost())
	text.text = "You have %s of %s boxes" % [Data.box_number(), Data.box_limit]
	button.disabled = Data.box_number_cost() > Data.money

func _on_Buy_button_up() -> void: # Used to pruchase
	var _cost = Data.box_number_cost()
	if _cost <= Data.money:
		Data.box_limit += 5
		Data.money -= _cost

func _on_Buy_mouse_entered() -> void:
	popup.show()

func _on_Buy_mouse_exited() -> void:
	popup.hide()
