extends Node2D
onready var button = $Buy
onready var text = $Text
var level: int = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.text = "Buy Level %s" % level
	update_interface()
	Data.connect("update_game_interface", self, "update_interface")

func update_interface() -> void:
	text.text = """Level %s cost: %s
Money Per Level %s: %s""" % [level, Data.cost[level], level, Data.earnings[level]]
	if Data.cost[level] <= Data.money:
		button.disabled = false
	else:
		button.disabled = true

func _on_Buy_button_up() -> void: # Used to pruchase and then increases the price when purchased
	if Data.cost[level] <= Data.money:
		Data.money -= Data.cost[level]
		Data.cost[level] = floor(1.15* Data.cost[level])
		var _instance = load("res://src/box.tscn")
		_instance = _instance.instance()
		_instance.level = level
		_instance.position = Vector2(512, 300)
		get_node("/root/Main/Game Field").call_deferred("add_child", _instance)
