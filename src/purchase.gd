extends Control
onready var sprite = $Popup/Sprite
onready var button = $Buy
onready var earnings = $Popup/Earnings
onready var number = $Popup/Number
onready var popup = $Popup
onready var sell = $Sell

var level: int = 1
var types: String = "box"
var cost: float # Stores the cost for the upgrade or purchase

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if types == "box":
		if Data.cost.size() <= level or Data.earnings.size() <= level: # Makes sure that this is not an invalid level
			self.queue_free()
		else:
			sprite.color = Color.from_hsv((120+20*level)/360.0, 0.9, 1, 1)
			update_interface()
	else:
		sprite.hide()
		sell.hide()
	update_interface()
	Data.connect("update_game_interface", self, "update_interface")

func update_interface() -> void: # Updates the buttons data
	if types == "ball":
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
	elif types == "goldenS":
		# Formula for calculating the cost
		cost = pow(10, log(Data.goldenStartChance  / -0.003)/log(0.9)+6)
		button.text = "Golden Spawn Speed for %s" % Data.beautify(cost)
		if cost <= Data.money:
			button.disabled = false
		else:
			button.disabled = true
	elif types == "goldenA":
		cost = pow(10, log(Data.goldenIncrease  / 0.000005)/log(1.22)+6) * 3
		button.text = "Golden Spawn Acceleration for %s" % Data.beautify(cost)
		if cost <= Data.money:
			button.disabled = false
		else:
			button.disabled = true
	elif types == "goldenL":
		cost = pow(10, log(Data.goldenLength)/log(1.2)+12)
		button.text = "Golden Length increase for %s" % Data.beautify(cost)
		earnings.text = "You are at x%s length" % Data.beautify(Data.goldenLength)
		number.text = "Upgrade to x%s" % Data.beautify(Data.goldenLength * 1.2)
		if cost <= Data.money:
			button.disabled = false
		else:
			button.disabled = true
	elif types == "goldenM":
		cost = pow(10, log(Data.goldenMagnitude)/log(1.2)+12) * 5 
		button.text = "Golden Magnitude increase for %s" % Data.beautify(cost)
		earnings.text = "You are at x%s bonus" % Data.beautify(Data.goldenMagnitude)
		number.text = "Upgrade to x%s" % Data.beautify(Data.goldenMagnitude * 1.2)
		if cost <= Data.money:
			button.disabled = false
		else:
			button.disabled = true
	else:
		if Data.box_number(level) > 0:
			sell.disabled = false
		else:
			sell.disabled = true
		button.text = "Buy Level %s for %s" % [level, Data.beautify(Data.cost[level])]
		earnings.text = "%s money per hit" % [Data.beautify(Data.earnings[level])]
		number.text = "You have %s" % Data.box_number(level)
		if Data.cost[level] <= Data.money and Data.box_number() < Data.box_limit:
			button.disabled = false
		else:
			button.disabled = true
		if level > Data.greatest_box + 1 and Data.cost[level] >= Data.money:
			self.visible = false
		else:
			self.visible = true

func _on_Buy_button_up() -> void: # Used to pruchase and then increases the price when purchased
	button.disabled = true
	if types == "ball": # Checks if a ball is being purchased
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
	elif types == "goldenS":
		if cost <= Data.money:
			Data.money -= cost
			var _increase = Data.goldenStartChance * -0.1
			Data.goldenStartChance *= 0.9
			Data.goldenChance += _increase
		update_interface()
	elif types == "goldenA":
		if cost <= Data.money:
			Data.money -= cost
			Data.goldenIncrease *= 1.22
		update_interface()
	elif types == "goldenL":
		if cost <= Data.money:
			Data.money -= cost
			Data.goldenLength *= 1.2
		update_interface()
	elif types == "goldenM":
		if cost <= Data.money:
			Data.money -= cost
			Data.goldenMagnitude *= 1.2
		update_interface()
	else:
		if Data.cost[level] <= Data.money and Data.box_number() < Data.box_limit:
			# Recalculates the greatest box.
			if Data.greatest_box < level:
				Data.greatest_box = level
			# Spends the money for the box.
			var _cost = Data.cost[level]
			Data.cost[level] = floor(1.15* Data.cost[level])
			Data.money -= _cost
			# Spawns the box.
			var _instance = load("res://src/box.tscn")
			_instance = _instance.instance()
			_instance.level = level
			_instance.position = Vector2(512, 300)
			get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func _on_Buy_mouse_entered() -> void:
	if types in ["goldenL", "goldenM"]:
		popup.show()
		popup.rect_size.x = earnings.rect_size.x + 20
		popup.rect_position.x = 1024 - popup.rect_size.x
	elif types == "box":
		popup.show()
		popup.rect_size.x = earnings.rect_size.x + sprite.rect_size.x + 30
		popup.rect_position.x = 1024 - popup.rect_size.x

func _on_Buy_mouse_exited() -> void:
	popup.hide()

func _on_Sell_button_up() -> void:
	if Data.box_number(level) > 0:
		sell.disabled = true
		Data.cost[level] = ceil(Data.cost[level] / 1.15)
		Data.money += ceil(Data.cost[level] * 0.5)
		for x in get_node("/root/Main/Game Field").get_children():
			if "box" in x.get_name():
				if x.level == level:
					x.delete()
					return
