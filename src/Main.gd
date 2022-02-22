extends Node2D
onready var _vBoxContainer: VBoxContainer = $TabContainer/Boxes/Boxes/VBoxContainer
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
		$TabContainer/Boxes/Boxes/VBoxContainer.call_deferred("add_child", _instance)
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

func _process(delta: float) -> void: # Checks if a button is pressed to change menu
	if Input.is_action_just_pressed("menu1"):
		_tab.current_tab = 1
	elif Input.is_action_just_pressed("menu2"):
		_tab.current_tab = 2
	elif Input.is_action_just_pressed("menu3"):
		_tab.current_tab = 3

func _on_Export_button_up() -> void:
	Data.save()
	get_tree().change_scene("res://src/Export.tscn")
