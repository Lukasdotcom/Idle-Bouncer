extends Control
onready var sprite = $Popup/Sprite
onready var button = $Buy
onready var earnings = $Popup/Earnings
onready var popup = $Popup

var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Data.cost.size() <= level or Data.earnings.size() <= level: # Makes sure that this is not an invalid level
		self.queue_free()
	else:
		sprite.set_modulate(Color.from_hsv((115+15*level)/360.0, 0.9, 1, 1))
		update_interface()
		Data.connect("update_game_interface", self, "update_interface")

func update_interface() -> void: # Updates the buttons data
	button.text = "Buy Level %s for %s" % [level, Data.beautify(Data.cost[level])]
	earnings.text = "%s money per hit" % [Data.beautify(Data.earnings[level])]
	if Data.cost[level] <= Data.money:
		button.disabled = false
	else:
		button.disabled = true

func _on_Buy_button_up() -> void: # Used to pruchase and then increases the price when purchased
	if Data.cost[level] <= Data.money:
		var _cost = Data.cost[level]
		Data.cost[level] = floor(1.15* Data.cost[level])
		Data.money -= _cost
		var _instance = load("res://src/box.tscn")
		_instance = _instance.instance()
		_instance.level = level
		_instance.position = Vector2(512, 300)
		get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func _on_Buy_mouse_entered() -> void:
	popup.show()

func _on_Buy_mouse_exited() -> void:
	popup.hide()
