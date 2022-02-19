extends Timer

var previous_earnings = [0] # Stores the previous earnings for every quater second of the last 25 seconds
var history = 100 # Stores the amount of data to save for earnings

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func earnings(number: float) -> void: # Used to send an earning message to 
	previous_earnings[-1] += number

func _on_Calculator_timeout() -> void:
	# Calculates the total money earned in the last 25 seconds
	var _total = 0
	for x in previous_earnings:
		_total += x
	# Calculates the average earning and updates the UI
	Data.MPS = _total / len(previous_earnings) * 4.0
	get_node("../Money Per Second").text = "MPS: %s" % Data.beautify(Data.MPS)
	# Adds data for the next quarter seconds
	previous_earnings.append(0)
	# Checks if the previous earnings list is too long and if it is removes an element from the list
	if len(previous_earnings) > history:
		previous_earnings.pop_front()
