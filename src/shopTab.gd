extends ScrollContainer

var label: String = "Label"

func _ready() -> void:
	$VBoxContainer/Label.text = label
	var _ball = load("res://src/purchase.tscn")
	for x in range(1, 20):
		var _instance = _ball.instance()
		_instance.level = x
		_instance.ball = true
		$VBoxContainer.call_deferred("add_child", _instance)
