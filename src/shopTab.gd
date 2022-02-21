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
		var _purchase = load("res://src/purchase.tscn")
		var _instance = _purchase.instance()
		_instance.types = "goldenS"
		$VBoxContainer.call_deferred("add_child", _instance)
		_instance = _purchase.instance()
		_instance.types = "goldenA"
		$VBoxContainer.call_deferred("add_child", _instance)
		_instance = _purchase.instance()
		_instance.types = "goldenL"
		$VBoxContainer.call_deferred("add_child", _instance)
		_instance = _purchase.instance()
		_instance.types = "goldenM"
		$VBoxContainer.call_deferred("add_child", _instance)
