extends Node2D
onready var _vBoxContainer: VBoxContainer = $TabContainer/Boxes/VBoxContainer
onready var _tab: TabContainer = $TabContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Data.start()
	update_interface()
	Data.connect("update_game_interface", self, "update_interface")
	Data.connect("ball_upgrades", self, "ball_upgrades")
	Data.connect("golden_upgrades", self, "golden_upgrades")
	var _purchase = load("res://src/purchase.tscn")
	var _instance
	for x in range(len(Data.cost)):
		if x == 0:
			continue
		_instance = _purchase.instance()
		_instance.level = x
		$TabContainer/Boxes/VBoxContainer.call_deferred("add_child", _instance)
	if Data.upgrades["ball"]: # Checks if ball upgrades is already on
		ball_upgrades()
	if Data.upgrades["golden"]:
		golden_upgrades()

func update_interface() -> void:
	get_node("/root/Main/Money").text = "Money: %s" % Data.beautify(Data.money)

func _on_Reset_button_up() -> void: # Used to reset the game
	Data.reset()

func upgrade(name: String) -> void: # Used to create a new tab in the shop
	var _shop = load("res://src/shopTab.tscn")
	_shop = _shop.instance()
	_shop.label = name
	_shop.name = name
	_tab.call_deferred("add_child", _shop)

func ball_upgrades() -> void: # Used to enable the ball upgrades
	upgrade("Ball")

func golden_upgrades() -> void:
	upgrade("Golden")

# Saves the game every 30 seconds and every time the save button is pressed
func _on_Save_timeout() -> void:
	Data.save()

func _on_Save_Button_button_up() -> void:
	Data.save()
