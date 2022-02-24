extends Node2D
var simulate = 1.0
var show = 1.0
var visibly = 0.0
var enabled = 0.0
var total = 0.0 setget changed
var disabledTotal = 0.0
var onlySimulate = false
signal update


func changed(value):
	total = value
	emit_signal("update")

func _on_change() -> void:
	simulate = get_node("/root/Main/TabContainer/Performance/Simulate").value / 100.0
	onlySimulate = get_node("/root/Main/TabContainer/Performance/CheckButton").pressed
	get_node("/root/Main/TabContainer/Performance/Show").editable = not onlySimulate
	show = get_node("/root/Main/TabContainer/Performance/Show").value / 100.0
	emit_signal("update")
