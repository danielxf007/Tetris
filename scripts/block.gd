extends Sprite2D

class_name Block


func destroy() -> void:
	hide()
	queue_free()
