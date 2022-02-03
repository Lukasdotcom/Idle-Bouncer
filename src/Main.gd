extends Node2D
onready var _vBoxContainer: VBoxContainer = $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_interface()
	Data.connect("update_game_interface", self, "update_interface")
	var _purchase = load("res://src/purchase.tscn")
	var _instance
	for x in range(len(Data.cost)):
		if x == 0:
			continue
		_instance = _purchase.instance()
		_instance.level = x
		_vBoxContainer.call_deferred("add_child", _instance)


func update_interface() -> void:
	get_node("/root/Main/Coins").text = "Coins: %s" % Data.beautify(Data.coins)
	get_node("/root/Main/Money").text = "Money: %s" % Data.beautify(Data.money)


func _on_Reset_button_up() -> void: # Used to reset the game
	Data.reset()
