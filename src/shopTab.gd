extends ScrollContainer

var label: String = "Label"

func _ready() -> void:
	$VBoxContainer/Label.text = label + " Shop"
	if label == "Ball":
		var _ball = load("res://src/purchase.tscn")
		for x in range(1, 20):
			var _instance = _ball.instance()
			_instance.level = x
			_instance.types = "ball"
			$VBoxContainer.call_deferred("add_child", _instance)
	if label == "Golden":
		var _instance = load("res://src/purchase.tscn")
		_instance = _instance.instance()
		_instance.types = "golden"
		$VBoxContainer.call_deferred("add_child", _instance)
