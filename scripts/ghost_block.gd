extends Sprite2D

class_name GhostBlock

func _ready():
	self_modulate.a = 0.70

func destroy() -> void:
	hide()
	queue_free()
