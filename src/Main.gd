extends Node2D
onready var _stats: RichTextLabel = $Stats

# Declare member variables here. Examples:
# var a: int = 2
# var b: String = "text"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Data.connect("update_game_interface", self, "update_interface")

func update_interface() -> void:
	_stats.text = """Money: %s
Round: %s""" % [Data.coins, Data.money]
