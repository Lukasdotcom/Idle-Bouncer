extends Timer

func _ready() -> void:
	self.start()

func _on_timeout() -> void:
	self.get_parent().timeout()
	self.queue_free()
