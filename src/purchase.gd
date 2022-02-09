extends Control
onready var sprite = $Popup/Sprite
onready var button = $Buy
onready var earnings = $Popup/Earnings
onready var popup = $Popup

var level: int = 1
var ball: bool = false
var cost: float # Stores the cost for the upgrade or purchase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not ball:
		if Data.cost.size() <= level or Data.earnings.size() <= level: # Makes sure that this is not an invalid level
			self.queue_free()
		else:
			sprite.set_modulate(Color.from_hsv((120+20*level)/360.0, 0.9, 1, 1))
			update_interface()
			Data.connect("update_game_interface", self, "update_interface")
	else:
		Data.connect("update_game_interface", self, "update_interface")
		update_interface()

func update_interface() -> void: # Updates the buttons data
	if ball:
		if len(Data.balls) >= level:
			cost = Data.balls[level-1][1]
			button.text = "Upgrade Ball #%s for %s" % [level, Data.beautify(cost)]
			self.show()
		elif len(Data.balls) + 1 == level:
			cost = pow(100, level) / 10.0
			button.text = "Buy Ball #%s for %s" % [level, Data.beautify(cost)]
			self.show()
		else:
			self.hide()
		if cost <= Data.money:
			button.disabled = false
		else:
			button.disabled = true
	else:
		button.text = "Buy Level %s for %s" % [level, Data.beautify(Data.cost[level])]
		earnings.text = "%s money per hit" % [Data.beautify(Data.earnings[level])]
		if Data.cost[level] <= Data.money:
			button.disabled = false
		else:
			button.disabled = true

func _on_Buy_button_up() -> void: # Used to pruchase and then increases the price when purchased
	if ball: # Checks if a ball is being purchased
		if cost <= Data.money:
			if len(Data.balls) >= level:
				Data.balls[level - 1][0] = floor(Data.balls[level - 1][0] * 1.075)
				Data.balls[level - 1][1] *= 10
				Data.money -= cost
			elif len(Data.balls) + 1 == level:
				Data.balls.append([200.0, cost * 10.0])
				Data.money -= cost
				Data.spawn_ball(level)
		update_interface()
	else:
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
	if not ball:
		popup.show()

func _on_Buy_mouse_exited() -> void:
	popup.hide()
